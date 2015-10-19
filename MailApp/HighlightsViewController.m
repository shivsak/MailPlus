//
//  HighlightsViewController.m
//  MailApp
//
//  Created by Shiv Sakhuja on 8/20/15.
//  Copyright © 2015 Shiv Sakhuja.  rights reserved.
//

#import "HighlightsViewController.h"
#import "DraggableViewBackground.h"
#import "CustomAlertView.h"
#import "ContextIOAPIInformation.h"
#import "SVProgressHUD.h"
#import "MessageViewController.h"

@interface HighlightsViewController ()

@end

@implementation HighlightsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self getMessages];
    });
    
    [self setupNavigationBar];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.2 alpha:1.0]];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.1 green:0.1 blue:0.2 alpha:1] CGColor], (id)[[UIColor colorWithRed:0.1 green:0.3 blue:0.4 alpha:1] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    [self setupNotifications];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupNavigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)setupNotifications {
    /**
     * Create the notification
     */
    self.minimalNotification = [JFMinimalNotification notificationWithStyle:JFMinimalNotificationStyleSuccess
                                                                      title:@"Unsubscribe Successful"
                                                                   subTitle:@"You have been unsubscribed from this list." dismissalDelay:1.5 touchHandler:^(void) {
                                                                       [self dismissNotification:self];
                                                                   }];
    
    
    
    /**
     * Set the desired font for the title and sub-title labels
     * Default is System Normal
     */
    UIFont* titleFont = [UIFont fontWithName:@"STHeitiK-Light" size:22];
    [self.minimalNotification setTitleFont:titleFont];
    UIFont* subTitleFont = [UIFont fontWithName:@"STHeitiK-Light" size:16];
    [self.minimalNotification setSubTitleFont:subTitleFont];
    
    /**
     * Set any necessary edge padding as needed
     */
    self.minimalNotification.edgePadding = UIEdgeInsetsMake(0, 0, 10, 0);
    
    /**
     * Add the notification to a view
     */
    
}

-(void)setupNavigationBar {
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.2 alpha:1]];
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
    [self.navigationController setTitle:@"MailApp"];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor whiteColor],
                                                                     NSForegroundColorAttributeName,
                                                                     [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0], NSFontAttributeName, nil]];
}

-(NSString *)getDate {
    self.dateAfter = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastHighlightDate"];
    
    //Remove Saved Date for Testing Purposes
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"lastHighlightDate"];
    
    if (self.dateAfter != NULL)
    {
        //Also check if self.dateAfter is not too far
    }
    else {
        //Use Today
        NSTimeInterval todayUnix = [[[NSDate date] dateByAddingTimeInterval:(-24*60*60)] timeIntervalSince1970];
        self.dateAfter = [NSString stringWithFormat:@"%f", todayUnix];
    }
    
    return self.dateAfter;
}

-(void)saveDate {
    NSString *todayDate = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
    [[NSUserDefaults standardUserDefaults] setObject:todayDate forKey:@"lastHighlightDate"];
}

-(void)getMessages
{
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:1 green:0.3 blue:0.6 alpha:1]];
    [SVProgressHUD show];
    //    int dateAfterInt = [[self getDate] intValue];
    //    NSLog(@"Getting Inbox Messages after %i", dateAfterInt);
    NSDictionary *params = @{@"limit": @(100),
                             @"folder": @"INBOX",
                             //                             @"date_after" : @(dateAfterInt)
                             };
    [[[ContextIOAPIInformation getAPIClient] getMessagesWithParams:params]
     executeWithSuccess:^(NSArray *responseDict) {
         self.importantMails = [responseDict mutableCopy];
         NSLog(@"Successfully downloaded messages: %@", self.importantMails);
         [SVProgressHUD showSuccessWithStatus:@"Success"];
         //         NSLog(@"Cards: %@", self.importantMails);
         //         NSLog(@"Sample Unsubscribe Header: %@", self.importantMails[6][@"list-headers"][@"list-unsubscribe"]);
         DraggableViewBackground *draggableBackground = [[DraggableViewBackground alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) data:self.importantMails];
         draggableBackground.APIClient = [ContextIOAPIInformation getAPIClient];
         draggableBackground.delegate = self;
         [self.view addSubview:draggableBackground];
         [self.view addSubview:self.minimalNotification];
         [self saveDate];
     } failure:^(NSError *error) {
         NSLog(@"error getting messages: %@", error);
         [SVProgressHUD showErrorWithStatus:@"Error"];
         //         CustomAlertView *alert = [[CustomAlertView alloc] init];
         //         [alert initWithTitle:@"Error!" message:@"Error connecting to the server. Please try again later." firstButtonText:nil cancelButtonText:@"Okay" withContainer:self];
         //         [alert.customAlertMessage setTextAlignment:NSTextAlignmentCenter];
         //         [alert.customAlertButtonCancel addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
         //
         //         [alert setTheme:4];
         //         [alert setPosition:0];
         //
         //         [alert showAlert];
     }];
}

-(IBAction)cancelButtonPressed:(id)sender {
    [[[sender superview] superview] removeFromSuperview];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

-(void)showMessage:(NSString *)messageID {
    MessageViewController *messageVC = (MessageViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"messageVC"];
    messageVC.messageID = messageID;
    [self.navigationController pushViewController:messageVC animated:YES];
}

-(void)unsubscribeToMailWithHeader:(NSString *)unsubscribeHeader {
    
    unsubscribeHeader = [unsubscribeHeader stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([[unsubscribeHeader substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"<"]) {
        unsubscribeHeader = [unsubscribeHeader substringWithRange:NSMakeRange(1, unsubscribeHeader.length - 2)];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:unsubscribeHeader]];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // Success handling here
    NSLog(@"Unsubscribe Successful");
    [self.minimalNotification show];
}



- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // Error handling here
    NSLog(@"Unsubscribe Failed With Error %@", error.localizedDescription);
    self.minimalNotification = [JFMinimalNotification notificationWithStyle:JFMinimalNotificationStyleError title:@"Error!" subTitle:@"You could not be unsubscribed from this list" dismissalDelay:1.5 touchHandler:^(void) {
        [self dismissNotification:self];
    }];
    [self.minimalNotification show];
}

- (IBAction)dismissNotification:(id)sender {
    [self.minimalNotification dismiss];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
