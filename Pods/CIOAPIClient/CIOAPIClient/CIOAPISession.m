//
//  CIOAPISession.m
//  CIOAPIClient
//
//  Created by Alex Pretzlav on 7/14/15.
//  Copyright (c) 2015 Context.io. All rights reserved.
//

#import "CIOAPISession.h"

NSString *const CIOAPISessionURLResponseErrorKey = @"io.context.error.response";

@interface CIODownloadTask : NSObject

@property (nullable, nonatomic) NSURL *saveToURL;
@property (nullable, nonatomic, copy) CIOSessionDownloadProgressBlock progressBlock;
@property (nullable, nonatomic, copy) void (^successBlock)();
@property (nullable, nonatomic, copy) void (^failureBlock)(NSError *error);

@end

@implementation CIODownloadTask

@end

#pragma mark -

@interface CIOAPISession () <NSURLSessionDownloadDelegate>

@property (nonatomic) NSURLSession *urlSession;
@property (nonatomic) NSIndexSet *acceptableStatusCodes;
// Mapping from Task ID to CIODownloadTask. Must only be read/written on the underlying NSURLSession queue.
@property (nonatomic) NSMutableDictionary *downloadTaskIDToCIOTask;

@end

@implementation CIOAPISession

- (instancetype)initWithConsumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                              token:(NSString *)token
                        tokenSecret:(NSString *)tokenSecret
                          accountID:(NSString *)accountID {
    if ((self = [super initWithConsumerKey:consumerKey
                            consumerSecret:consumerSecret
                                     token:token
                               tokenSecret:tokenSecret
                                 accountID:accountID])) {
        self.urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                        delegate:self
                                                   delegateQueue:nil];
        // Hat tip to AFNetworking
        self.acceptableStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
        self.downloadTaskIDToCIOTask = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)executeDictionaryRequest:(CIODictionaryRequest *)request
                         success:(void (^)(NSDictionary *))success
                         failure:(void (^)(NSError *))failure {
    [self executeRequest:request success:success failure:failure];
}

- (void)executeArrayRequest:(CIOArrayRequest *)request
                    success:(void (^)(NSArray *))success
                    failure:(void (^)(NSError *))failure {
    [self executeRequest:request success:success failure:failure];
}

- (void)executeStringRequest:(CIOStringRequest *)request
                     success:(void (^)(NSString *))success
                     failure:(void (^)(NSError *))failure {
    [self executeRequest:request success:success failure:failure];
}

- (void)downloadRequest:(CIORequest *)request
              toFileURL:(NSURL *)saveToURL
                success:(void (^)())successBlock
                failure:(void (^)(NSError *))failureBlock
               progress:(void (^)(int64_t, int64_t, int64_t))progressBlock {
    NSURLSessionDownloadTask *downloadTask = [self.urlSession downloadTaskWithRequest:request.urlRequest];
    CIODownloadTask *cioTask = [CIODownloadTask new];
    cioTask.saveToURL = saveToURL;
    cioTask.successBlock = successBlock;
    cioTask.failureBlock = failureBlock;
    cioTask.progressBlock = progressBlock;
    [self.urlSession.delegateQueue addOperationWithBlock:^{
        self.downloadTaskIDToCIOTask[@(downloadTask.taskIdentifier)] = cioTask;
        [downloadTask resume];
    }];
}

#pragma mark -

// If `block` is nonnull, calls it with `parameter` on the main dispatch queue
- (void)_dispatchMain:(nullable void (^)(id param))block parameter:(id)parameter {
    if (block) {
        dispatch_async(dispatch_get_main_queue(), ^{
          block(parameter);
        });
    }
}

- (NSError *)errorForResponse:(NSHTTPURLResponse *)response responseObject:(id)responseObject {
    NSString *errorString = nil;
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        if ([responseObject[@"type"] isEqual:@"error"]) {
            errorString = responseObject[@"value"];
        } else if ([responseObject[@"success"] isEqual:@NO]) {
            NSArray *responseValues =
                @[responseObject[@"feedback_code"] ?: @"", responseObject[@"connectionLog"] ?: @""];
            errorString = [responseValues componentsJoinedByString:@"\n"];
        }
    }
    if (!errorString) {
        NSInteger code = response.statusCode;
        errorString = [NSString stringWithFormat:@"Invalid server response: %@ (%ld)",
                                                 [NSHTTPURLResponse localizedStringForStatusCode:code], (long)code];
    }
    return
        [NSError errorWithDomain:@"io.context.error.statuscode"
                            code:NSURLErrorBadServerResponse
                        userInfo:@{NSLocalizedDescriptionKey: errorString, CIOAPISessionURLResponseErrorKey: response}];
}

- (id)parseResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError **)error {
    id responseObject = nil;
    if (data && [data length] > 0) {
        if ([[response MIMEType] isEqualToString:@"application/json"]) {
            NSError *jsonError;
            responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (jsonError) {
                *error = jsonError;
                return nil;
            }
        } else {
            NSStringEncoding encoding = NSUTF8StringEncoding;
            if (response.textEncodingName) {
                encoding = CFStringConvertEncodingToNSStringEncoding(
                    CFStringConvertIANACharSetNameToEncoding((__bridge CFStringRef)response.textEncodingName));
            }
            responseObject = [[NSString alloc] initWithData:data encoding:encoding];
        }
    }
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSUInteger code = (NSUInteger)[(NSHTTPURLResponse *)response statusCode];
        if (![self.acceptableStatusCodes containsIndex:code]) {
            if (error) {
                *error = [self errorForResponse:(NSHTTPURLResponse *)response responseObject:responseObject];
            }
            return responseObject;
        }
    }
    return responseObject;
}

- (void)executeRequest:(CIORequest *)request
               success:(void (^)(id responseObject))successBlock
               failure:(void (^)(NSError *error))failureBlock {
    NSURLSessionDataTask *dataTask =
    [self.urlSession dataTaskWithRequest:request.urlRequest
                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                           if (error) {
                               [self _dispatchMain:failureBlock parameter:error];
                               return;
                           }
                           id responseObject = [self parseResponse:response data:data error:&error];
                           if (error) {
                               [self _dispatchMain:failureBlock parameter:error];
                               return;
                           }
                           error = [request validateResponseObject:responseObject];
                           if (error) {
                               [self _dispatchMain:failureBlock parameter:error];
                               return;
                           }
                           [self _dispatchMain:successBlock parameter:responseObject];
                       }];
    [dataTask resume];
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    CIODownloadTask *cioTask = self.downloadTaskIDToCIOTask[@(task.taskIdentifier)];
    if (cioTask) {
        if (error) {
            [self _dispatchMain:cioTask.failureBlock parameter:error];
        } else if (cioTask.successBlock) {
            dispatch_async(dispatch_get_main_queue(), cioTask.successBlock);
        }
        [self.downloadTaskIDToCIOTask removeObjectForKey:@(task.taskIdentifier)];
    }
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session
                 downloadTask:(NSURLSessionDownloadTask *)downloadTask
                 didWriteData:(int64_t)bytesWritten
            totalBytesWritten:(int64_t)totalBytesWritten
    totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    CIODownloadTask *cioTask = self.downloadTaskIDToCIOTask[@(downloadTask.taskIdentifier)];
    if (cioTask.progressBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
          cioTask.progressBlock(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
        });
    }
}

- (void)URLSession:(NSURLSession *)session
                 downloadTask:(NSURLSessionDownloadTask *)downloadTask
    didFinishDownloadingToURL:(NSURL *)location {
    CIODownloadTask *cioTask = self.downloadTaskIDToCIOTask[@(downloadTask.taskIdentifier)];
    if (cioTask.saveToURL) {
        NSError *error = nil;
        [[NSFileManager defaultManager] moveItemAtURL:location toURL:cioTask.saveToURL error:&error];
        if (error) {
            [self _dispatchMain:cioTask.failureBlock parameter:error];
            [self.downloadTaskIDToCIOTask removeObjectForKey:@(downloadTask.taskIdentifier)];
        }
    }
}

@end


@implementation CIODictionaryRequest (CIOAPISession)

- (void)executeWithSuccess:(nullable void (^)(NSDictionary * __nonnull))success failure:(nullable void (^)(NSError * __nonnull))failure {
    NSParameterAssert([self.client isKindOfClass:[CIOAPISession class]]);
    [(CIOAPISession*)self.client executeDictionaryRequest:self success:success failure:failure];
}

@end

@implementation CIOArrayRequest (CIOAPISession)

- (void)executeWithSuccess:(nullable void (^)(NSArray * __nonnull))success failure:(nullable void (^)(NSError * __nonnull))failure {
    NSParameterAssert([self.client isKindOfClass:[CIOAPISession class]]);
    [(CIOAPISession*)self.client executeArrayRequest:self success:success failure:failure];
}

@end

@implementation CIOStringRequest (CIOAPISession)

- (void)executeWithSuccess:(nullable void (^)(NSString * __nonnull))success failure:(nullable void (^)(NSError * __nonnull))failure {
    NSParameterAssert([self.client isKindOfClass:[CIOAPISession class]]);
    [(CIOAPISession*)self.client executeStringRequest:self success:success failure:failure];
}

@end
