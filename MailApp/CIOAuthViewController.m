//
//  CIOAuthViewController.m
//  Context.IO iOS Example App
//
//  Created by Kevin Lord on 1/16/13.
//  Copyright (c) 2013 Context.IO. All rights reserved.
//

#import "CIOAuthViewController.h"
#import "BorderedButton.h"

@interface CIOAuthViewController ()

@property (nonatomic, strong) CIOAPISession *APIClient;
@property (nonatomic, assign) BOOL allowCancel;
@property (nonatomic, assign) NSInteger selectedProviderType;
@property (nonatomic, strong) UILabel *instructionsTextView;
@property (nonatomic, strong) UIButton *gmailButton;
@property (nonatomic, strong) UIButton *yahooButton;
@property (nonatomic, strong) UIButton *aolButton;

- (void)cancelButtonPressed;
- (void)providerButtonPressed:(id)sender;

@end

@implementation CIOAuthViewController

@synthesize delegate = _delegate;
@synthesize APIClient = _APIClient;
@synthesize allowCancel = _allowCancel;
@synthesize selectedProviderType = _selectedProviderType;
@synthesize instructionsTextView = _instructionsTextView;
@synthesize gmailButton = _gmailButton;
@synthesize yahooButton = _yahooButton;
@synthesize aolButton = _aolButton;

- (id)initWithAPIClient:(CIOAPISession *)APIClient allowCancel:(BOOL)allowCancel {
    
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.APIClient = APIClient;
        self.allowCancel = allowCancel;
    }
    
    return self;
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.2 alpha:1.0]];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.1 green:0.1 blue:0.2 alpha:1] CGColor], (id)[[UIColor colorWithRed:0.1 green:0.3 blue:0.4 alpha:1] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    self.title = NSLocalizedString(@"Connect Account", @"");
    
    //    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-default.png"]];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    if (self.allowCancel == YES) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
    }
    
    self.instructionsTextView = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width - 40, 40)];
    self.instructionsTextView.numberOfLines = 0;
    self.instructionsTextView.backgroundColor = [UIColor clearColor];
    self.instructionsTextView.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0f];
    self.instructionsTextView.textColor = [UIColor colorWithWhite:1 alpha:1.0f];
    self.instructionsTextView.textAlignment = NSTextAlignmentCenter;
    self.instructionsTextView.text = NSLocalizedString(@"Sign in to connect your email account with Message Finder.", @"");
    [self.view addSubview:self.instructionsTextView];
    
    UIImage *providerButtonBgImage = [[UIImage imageNamed:@"button-provider-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(76.0f, 7.0f, 76.0f, 7.0f)];
    
    self.gmailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.gmailButton.tag = CIOEmailProviderTypeGmail;
//    [self.gmailButton setBackgroundImage:providerButtonBgImage forState:UIControlStateNormal];
    //    [self.gmailButton setImage:[UIImage imageNamed:@"button-provider-gmail"] forState:UIControlStateNormal];
    self.gmailButton.layer.cornerRadius = 20.0f;
    self.gmailButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.gmailButton.layer.borderWidth = 1.0f;
    self.gmailButton.layer.masksToBounds = YES;
    [self.gmailButton setTitle:@"Gmail" forState:UIControlStateNormal];
    [self.gmailButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.gmailButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f]];
    [self.gmailButton addTarget:self action:@selector(providerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.gmailButton];
    
    self.yahooButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.yahooButton.tag = CIOEmailProviderTypeYahoo;
    self.yahooButton.layer.cornerRadius = 20.0f;
    self.yahooButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.yahooButton.layer.borderWidth = 1.0f;
    self.yahooButton.layer.masksToBounds = YES;
//    [self.yahooButton setBackgroundImage:providerButtonBgImage forState:UIControlStateNormal];
    //    [self.yahooButton setImage:[UIImage imageNamed:@"button-provider-yahoo"] forState:UIControlStateNormal];
    [self.yahooButton setTitle:@"Yahoo" forState:UIControlStateNormal];
    [self.yahooButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.yahooButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f]];
    [self.yahooButton addTarget:self action:@selector(providerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.yahooButton];
    
    self.aolButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.aolButton.tag = CIOEmailProviderTypeAOL;
    self.aolButton.layer.cornerRadius = 20.0f;
    self.aolButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.aolButton.layer.borderWidth = 1.0f;
    self.aolButton.layer.masksToBounds = YES;
//    [self.aolButton setBackgroundImage:providerButtonBgImage forState:UIControlStateNormal];
    //    [self.aolButton setImage:[UIImage imageNamed:@"button-provider-aol"] forState:UIControlStateNormal];
    [self.aolButton setTitle:@"AOL" forState:UIControlStateNormal];
    [self.aolButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.aolButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f]];
    [self.aolButton addTarget:self action:@selector(providerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.aolButton];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    self.instructionsTextView.frame = CGRectMake(30.0f, 10.0f, (self.view.frame.size.width - 60.0f), 50.0f);
    
    self.gmailButton.frame = CGRectMake(10.0f,
                                        (self.instructionsTextView.frame.origin.y + self.instructionsTextView.frame.size.height + 30.0f),
                                        (self.view.frame.size.width - 20.0f),
                                        60.0f);
    
    self.yahooButton.frame = CGRectMake(10.0f,
                                        (self.gmailButton.frame.origin.y + self.gmailButton.frame.size.height + 20.0f),
                                        (self.view.frame.size.width - 20.0f),
                                        60.0f);
    
    self.aolButton.frame = CGRectMake(10.0f,
                                      (self.yahooButton.frame.origin.y + self.yahooButton.frame.size.height + 20.0f),
                                      (self.view.frame.size.width - 20.0f),
                                      60.0f);
}

#pragma mark Actions

- (void)cancelButtonPressed {
    [self.delegate userCancelledLogin];
}

- (void)providerButtonPressed:(id)sender {
    
    CIOEmailProviderType providerType = ((UIButton *)sender).tag;
    self.selectedProviderType = providerType;
    
    //Provided to hide the name fields in the auth web page
    NSMutableDictionary *mutableParams = [NSMutableDictionary dictionary];
    [mutableParams setValue:@"*hidden*" forKey:@"first_name"];
    [mutableParams setValue:@"*hidden*" forKey:@"last_name"];
    
    [[self.APIClient beginAuthForProviderType:providerType callbackURLString:@"cio-api-auth://" params:mutableParams]
     executeWithSuccess:^(NSDictionary *responseDict) {
         
         NSURL *authRedirectURL = [self.APIClient redirectURLFromResponse:responseDict];
         //clear context.io cookies before using the new web view
         NSHTTPCookieStorage *sharedCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
         for (NSHTTPCookie *cookie in [sharedCookieStorage cookies]) {
             if ([cookie.domain rangeOfString:@"context.io"].location != NSNotFound) {
                 [sharedCookieStorage deleteCookie:cookie];
             }
         }
         
         UIViewController *webViewController = [[UIViewController alloc] initWithNibName:nil bundle:nil];
         webViewController.edgesForExtendedLayout = UIRectEdgeNone;
         UIWebView *loginWebView = [[UIWebView alloc] initWithFrame:self.view.frame];
         loginWebView.delegate = self;
         webViewController.view = loginWebView;
         [self.navigationController pushViewController:webViewController animated:YES];
         
         [loginWebView loadRequest:[NSURLRequest requestWithURL:authRedirectURL]];
     } failure:^(NSError *error) {
         NSLog(@"error creating connect token: %@", error);
         NSString *title = @"Error";
         NSHTTPURLResponse *response = error.userInfo[CIOAPISessionURLResponseErrorKey];
         if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
             title = [NSString stringWithFormat:@"Error Code %ld", (long)((NSHTTPURLResponse*)response).statusCode];
         }
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                         message:error.localizedDescription
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
         [alert show];
     }];
}

#pragma mark UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if ([request.URL.scheme isEqualToString:@"cio-api-auth"]) {
        
        NSString *connectToken = nil;
        for (NSString *queryParam in [request.URL.query componentsSeparatedByString:@"&"]) {
            
            NSArray *queryParamPair = [queryParam componentsSeparatedByString:@"="];
            
            if ([[queryParamPair objectAtIndex:0] isEqualToString:@"contextio_token"]) {
                connectToken = [queryParamPair objectAtIndex:1];
                NSLog(@"%@", queryParamPair);
            }
        }
        
        if (self.APIClient.isAuthorized) {
            [self.delegate userCompletedLogin];
        } else {
            [[self.APIClient fetchAccountWithConnectToken:connectToken]
             executeWithSuccess:^(NSDictionary *responseObject) {
                 NSLog(@"Response object %@", responseObject);
                 if ([self.APIClient completeLoginWithResponse:responseObject saveCredentials:YES]) {
                     [self.delegate userCompletedLogin];
                 }
                 else {
                     NSLog(@"Missing credentials from Authentication response");
                     [self.delegate userCancelledLogin];
                 }
             } failure:^(NSError *error) {
                 [self.delegate userCancelledLogin];
                 NSLog(@"error getting connect token details: %@", error);
             }];
        }
        return NO;
    }
    
    return YES;
}

@end
