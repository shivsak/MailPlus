//
//  ContextIOAPIInformation.m
//  MailApp
//
//  Created by Shiv Sakhuja on 8/25/15.
//  Copyright © 2015 Shiv Sakhuja. All rights reserved.
//

#import "ContextIOAPIInformation.h"

static CIOAPISession *APIClient = nil;

@implementation ContextIOAPIInformation

+(CIOAPISession *)getAPIClient {
    return APIClient;
}

+(void)setAPIClient:(CIOAPISession *)client {
    APIClient = client;
}

@end
