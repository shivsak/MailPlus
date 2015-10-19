//
//  BaseViewController.m
//  MailApp
//
//  Created by Shiv Sakhuja on 8/17/15.
//  Copyright © 2015 Shiv Sakhuja. All rights reserved.
//

#import "BaseViewController.h"
#import "AttachmentsViewController.h"
#import "PhotosViewController.h"
#import "HighlightsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIButton+PPiAwesome.h"
#import "LoginViewController.h"
#import "ContextIOAPIInformation.h"
#import "CustomAlertView.h"
#import "ComposeViewController.h"
#import "ViewController.h"

@interface BaseViewController ()

@property BOOL isPageMenuSetup;
@property BOOL hasShownHighlights;
@property BOOL lockNavBarAsHidden;
@property (strong, nonatomic) ViewController *inboxVC;
@property (strong, nonatomic) PhotosViewController *photosVC;
@property (strong, nonatomic) AttachmentsViewController *attachmentsVC;

@end

BOOL isMenuOpen;
int MENU_WIDTH = 130;
int MENU_HEIGHT = 667;
int MAIN_FULL_WIDTH = 375;
int MAIN_FULL_HEIGHT = 667;
int MAIN_COMPRESSED_WIDTH = 275;
int MAIN_COMPRESSED_HEIGHT = 488;


@implementation BaseViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.lockNavBarAsHidden = NO;
    [self.navigationController setNavigationBarHidden:YES
                                             animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:self.lockNavBarAsHidden
                                             animated:animated];
}

- (void)presentModal
{
    self.lockNavBarAsHidden = YES;
    UINavigationController *navController;
    navController = [[UINavigationController alloc] initWithRootViewController:[UIViewController new]];
    [self presentViewController:navController
                       animated:YES
                     completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupPagingMenu];
    [self setupNavigationBar];
    [self setupSideView];
    [self setupNotifications];
    
    [self checkInternet:nil];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self createMailAppFolders];
        dispatch_async(dispatch_get_main_queue(), ^{
            //Main Queue
            [self showHighlights:self];
        });
    });
    
    
    [self setupMenuButtons];
    
    NSLog(@"BaseViewController API Client: %@", [ContextIOAPIInformation getAPIClient]);
    
    // Gradient
    [self.view setBackgroundColor:[UIColor blackColor]];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.4 green:0.15 blue:0.44 alpha:1] CGColor], (id)[[UIColor colorWithRed:0.2 green:0.1 blue:0.3 alpha:1] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    [self.topBar setBackgroundColor:[UIColor blackColor]];
    
    isMenuOpen = false;
    [self closeMenu:self];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    //    [self.view setBackgroundColor:[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1]];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupNotifications {
    /**
     * Create the notification
     */
    self.minimalNotification = [JFMinimalNotification notificationWithStyle:JFMinimalNotificationStyleWarning
                                                                      title:@"No Internet"
                                                                   subTitle:@"Tap to dismiss." dismissalDelay:0.0 touchHandler:^(void) {
                                                                       [self dismissNotification:self];
                                                                   }];
    
    
    
    /**
     * Set the desired font for the title and sub-title labels
     * Default is System Normal
     */
    UIFont *titleFont = [UIFont fontWithName:@"HelveticaNeue" size:19.0f];
    [self.minimalNotification setTitleFont:titleFont];
    UIFont *subTitleFont = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
    [self.minimalNotification setSubTitleFont:subTitleFont];
    
    /**
     * Set any necessary edge padding as needed
     */
    self.minimalNotification.edgePadding = UIEdgeInsetsMake(0, 0, 10, 0);
    
    /**
     * Add the notification to a view
     */
    [self.view addSubview:self.minimalNotification];
}


-(void)setupNavigationBar {
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:1 green:0.1 blue:0.2 alpha:1]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self setTitle:@"Mail"];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor whiteColor],
                                                                     NSForegroundColorAttributeName,
                                                                     [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0], NSFontAttributeName, nil]];
}


#pragma mark - Check for Internet;

-(IBAction)checkInternet:(id)sender {
    if (![self isInternetConnection]) {
        [self.minimalNotification show];
    }
}

-(BOOL)isInternetConnection {
    //   Check for Internet Connection
    NSString *connect = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.apple.com"]] encoding:NSUTF8StringEncoding error:nil];
    //    NSLog(@"%@", connect);
    if (connect == NULL) {
        //No Internet Connection
        return FALSE;
    }
    else {
        return TRUE;
    }
    
}

//-(void)showNoInternetMessage {
//    CustomAlertView *alert = [[CustomAlertView alloc] init];
//    [alert initWithTitle:@"No Internet" message:@"You do not have a working internet connection. Please connect to the internet and try again." firstButtonText:@"Retry" cancelButtonText:@"Cancel" withContainer:self];
//    [alert.customAlertButton addTarget:self action:@selector(checkInternet:) forControlEvents:UIControlEventTouchUpInside];
//    [alert.customAlertButtonCancel addTarget:self action:@selector(removeAlert:) forControlEvents:UIControlEventTouchUpInside];
//    [alert setTheme:0];
//    [alert setPosition:0];
//    [alert showAlert];
//}

-(IBAction)removeAlert:(id)sender {
    [[[sender superview] superview] removeFromSuperview];
}





-(void)setupMenuButtons {
    //    NSString *unselectedIcon = @"fa-circle-o";
    //    UIColor *foregroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7];
    
    //    receiptsButton = [UIButton buttonWithType:UIButtonTypeCustom text:@"Receipts" icon:unselectedIcon textAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:foregroundColor} andIconPosition:IconPositionLeft];
    //    [receiptsButton setIsAwesome:YES];
    //    [receiptsButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    //    [receiptsButton setFrame:CGRectMake(10, 100, 100, 30)];
    //    [self.sideView addSubview:receiptsButton];
    //
    //
    //    highlightsButton = [UIButton buttonWithType:UIButtonTypeSystem text:@"Highlights" icon:unselectedIcon textAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:foregroundColor} andIconPosition:IconPositionLeft];
    //    [highlightsButton setIsAwesome:YES];
    //    [highlightsButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    //    [highlightsButton setFrame:CGRectMake(10, receiptsButton.frame.origin.y+receiptsButton.frame.size.height + 10, 100, 30)];
    //    [highlightsButton addTarget:self action:@selector(showHighlights) forControlEvents:UIControlEventTouchUpInside];
    //    [self.sideView addSubview:highlightsButton];
    //
    //
    //
    //    allButton = [UIButton buttonWithType:UIButtonTypeSystem text:@"All" icon:unselectedIcon textAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:foregroundColor} andIconPosition:IconPositionLeft];
    //    [allButton setIsAwesome:YES];
    //    [allButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    //    [allButton setFrame:CGRectMake(10, highlightsButton.frame.origin.y+highlightsButton.frame.size.height + 70, 100, 30)];
    //    allButton.tag = 0;
    //    [allButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    //    [allButton addTarget:self action:@selector(showMailbox:) forControlEvents:UIControlEventTouchUpInside];
    //    [self.sideView addSubview:allButton];
    //
    //
    //    importantButton = [UIButton buttonWithType:UIButtonTypeSystem text:@"Important" icon:unselectedIcon textAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:foregroundColor} andIconPosition:IconPositionLeft];
    //    [importantButton setIsAwesome:YES];
    //    [importantButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    //    [importantButton setFrame:CGRectMake(10, allButton.frame.origin.y+allButton.frame.size.height + 10, 100, 30)];
    //    importantButton.tag = 1;
    //    [importantButton addTarget:self action:@selector(showMailbox:) forControlEvents:UIControlEventTouchUpInside];
    //    [importantButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    //    [self.sideView addSubview:importantButton];
    //
    //
    //    sentButton = [UIButton buttonWithType:UIButtonTypeSystem text:@"Sent" icon:unselectedIcon textAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:foregroundColor} andIconPosition:IconPositionLeft];
    //    [sentButton setIsAwesome:YES];
    //    [sentButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    //    [sentButton setFrame:CGRectMake(10, importantButton.frame.origin.y+importantButton.frame.size.height + 10, 100, 30)];
    //    sentButton.tag = 2;
    //    [sentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    //    [sentButton addTarget:self action:@selector(showMailbox:) forControlEvents:UIControlEventTouchUpInside];
    //    [self.sideView addSubview:sentButton];
    
    
    
}

-(IBAction)showMailbox:(id)sender {
    NSLog(@"ShowMailbox Running");
    [sender setHighlighted:YES];
    switch ([sender tag]) {
        case 0:
            //All
            self.inboxVC.filter = @"All";
            self.topBarTitle.text = @"All Mail";
            break;
            
        case 1:
            //Imp
            self.inboxVC.filter = @"Imp";
            self.topBarTitle.text = @"Important";
            break;
            
        case 2:
            //Sent
            self.inboxVC.filter = @"Sent";
            self.topBarTitle.text = @"Sent";
            break;
            
        case 3:
            //Drafts
            self.inboxVC.filter = @"Drafts";
            self.topBarTitle.text = @"Drafts";
            break;
            
        case 4:
            //Unread
            self.inboxVC.filter = @"Unread";
            self.topBarTitle.text = @"Unread";
            break;
            
            
        default:
            break;
    }
    
    self.topBarTitle.text = [self.topBarTitle.text uppercaseString];
    [self closeMenu:self];
    [self.inboxVC applyFilter];
}

-(void)setupSideView {
    MENU_HEIGHT = self.view.frame.size.height;
    MAIN_FULL_WIDTH = self.view.frame.size.width;
    MAIN_FULL_HEIGHT = self.view.frame.size.height;
    [self.sideView setBackgroundColor:[UIColor clearColor]];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - CAPSPageMenu Methods

-(void)setupPagingMenu {
    // Array to keep track of controllers in page menu
    NSMutableArray *controllerArray = [NSMutableArray array];
    
    // Create variables for all view controllers you want to put in the
    // page menu, initialize them, and add each to the controller array.
    // (Can be any UIViewController subclass)
    // Make sure the title property of all view controllers is set
    // Example:
    
    self.inboxVC = (ViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"inboxVC"];
    self.inboxVC.title = @"MESSAGES";
    self.inboxVC.navController = self.navigationController;
    self.inboxVC.filter = @"Imp";
    self.topBarTitle.text = @"Important";
    self.topBarTitle.text = [self.topBarTitle.text uppercaseString];
    self.inboxDelegate = self.inboxVC;
    self.inboxVC.delegate = self;
    [controllerArray addObject:self.inboxVC];
    
    self.attachmentsVC = (AttachmentsViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"attachmentsVC"];
    self.attachmentsVC.title = @"ATTACHMENTS";
    self.attachmentsVC.navController = self.navigationController;
    self.attachmentsVC.senderEmail = @"-99";
    self.attachmentsDelegate = self.attachmentsVC;
    [controllerArray addObject:self.attachmentsVC];
    
    self.photosVC = (PhotosViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"photosVC"];
    self.photosVC.title = @"PHOTOS";
    self.photosVC.navController = self.navigationController;
    self.photosVC.senderEmail = @"-99";
    self.photosDelegate = self.photosVC;
    [controllerArray addObject:self.photosVC];
    
    // Customize page menu to your liking (optional) or use default settings by sending nil for 'options' in the init
    // Example:
    //    NSDictionary *parameters = @{CAPSPageMenuOptionMenuItemSeparatorWidth: @(4.3),
    //                                 CAPSPageMenuOptionUseMenuLikeSegmentedControl: @(YES),
    //                                 CAPSPageMenuOptionMenuItemSeparatorPercentageHeight: @(0.1)
    //                                 };
    
    NSDictionary *parameters = @{
                                 CAPSPageMenuOptionScrollMenuBackgroundColor: [UIColor colorWithRed:0.1 green:0.1 blue:0.2 alpha:0.2],
                                 CAPSPageMenuOptionViewBackgroundColor: [UIColor blackColor],
                                 CAPSPageMenuOptionSelectionIndicatorColor: [UIColor colorWithRed:1 green:0.2 blue:0.3 alpha:0],
                                 CAPSPageMenuOptionBottomMenuHairlineColor: [UIColor clearColor],
                                 CAPSPageMenuOptionMenuItemSeparatorColor: [UIColor clearColor],
                                 CAPSPageMenuOptionMenuItemSeparatorWidth: @(4.0f),
                                 CAPSPageMenuOptionMenuItemWidth: @(95.0),
                                 CAPSPageMenuOptionUnselectedMenuItemLabelColor: [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1],
                                 CAPSPageMenuOptionSelectedMenuItemLabelColor: [UIColor colorWithRed:1 green:1 blue:1 alpha:1],
                                 CAPSPageMenuOptionMenuItemFont: [UIFont fontWithName:@"Avenir-Medium" size:13.0],
                                 CAPSPageMenuOptionMenuHeight: @(50.0),
                                 CAPSPageMenuOptionCenterMenuItems: @(YES)
                                 };
    
    
    // Initialize page menu with controller array, frame, and optional parameters
    self.pageMenu = [[CAPSPageMenu alloc] initWithViewControllers:controllerArray frame:CGRectMake(0.0, 50.0, self.view.frame.size.width, self.view.frame.size.height) options:parameters];
    
    // Lastly add page menu as subview of base view controller view
    // or use pageMenu controller in you view hierachy as desired
    [self.view addSubview:self.pageMenu.view];
    self.isPageMenuSetup = YES;
}

-(void)resetPagingMenuFrame {
    [self.pageMenu.view removeFromSuperview];
    //    [self setupPagingMenu];
}

-(IBAction)showHighlights:(id)sender {
    HighlightsViewController *highlightsVC = (HighlightsViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"highlightsVC"];
    [self.navigationController pushViewController:highlightsVC animated:YES];
}

#pragma mark - MailApp Folder

-(void)createMailAppFolders {
    
    NSString *archivedFolderPath = @"MailApp/Archived";
    
    [[[ContextIOAPIInformation getAPIClient] getFolderWithPath:archivedFolderPath sourceLabel:@"0" params:nil] executeWithSuccess:^(NSDictionary *responseDict) {
        NSLog(@"Folder %@ exists", archivedFolderPath);
    }
                                                                                                                          failure:^(NSError *error) {
                                                                                                                              [[[ContextIOAPIInformation getAPIClient] createFolderWithPath:archivedFolderPath sourceLabel:@"0" params:nil] executeWithSuccess:^(NSDictionary *responseDict) {
                                                                                                                                  if ([[responseDict objectForKey:@"success"] boolValue] == 1) {
                                                                                                                                      NSLog(@"Folder Created");
                                                                                                                                  }
                                                                                                                              }
                                                                                                                                                                                                                                                       failure:^(NSError *error) {
                                                                                                                                                                                                                                                           NSLog(@"Folder could not be created %@", error);
                                                                                                                                                                                                                                                       }];
                                                                                                                              
                                                                                                                          }];
}



-(void)showSideView:(id)sender {
    if (!isMenuOpen) {
        [self.topBar setBackgroundColor:[UIColor clearColor]];
        
        //Capture Screenshot of PageMenu View
        UIImage *viewRenderedImage = [self imageByRenderingView:self.pageMenu.view];
        self.stillImageView = [[UIImageView alloc] initWithFrame:self.pageMenu.view.frame];
        self.stillImageView.image = viewRenderedImage;
        [self.stillImageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.stillImageView setBackgroundColor:[UIColor clearColor]];
        [self.stillImageView setHidden:NO];
        [self.stillImageView.layer setCornerRadius:10.0f];
        [self.stillImageView.layer setMasksToBounds:YES];
        [self.view addSubview:self.stillImageView];
        
        //Move in SideView
        CGRect frame_sideView = self.sideView.frame;
        frame_sideView = CGRectMake(0, 0, MENU_WIDTH, MENU_HEIGHT);
        
        MAIN_COMPRESSED_WIDTH = (self.view.frame.size.width - MENU_WIDTH);
        MAIN_COMPRESSED_HEIGHT = (self.view.frame.size.height/self.view.frame.size.width)*MAIN_COMPRESSED_WIDTH;
        
        //Move out MainView
        CGRect frame_main = self.pageMenu.view.frame;
        frame_main = CGRectMake(frame_sideView.size.width + (self.view.frame.size.width - MENU_WIDTH - MAIN_COMPRESSED_WIDTH)/2, (self.view.frame.size.height - MAIN_COMPRESSED_HEIGHT)/2, MAIN_COMPRESSED_WIDTH, MAIN_COMPRESSED_HEIGHT);
        
        self.stillImageViewButton = [[UIButton alloc] initWithFrame:frame_main];
        [self.stillImageViewButton addTarget:self action:@selector(closeMenu:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.stillImageViewButton];
        
        [UIView setAnimationDuration:0.3];
        [UIView beginAnimations:nil context:nil];
        
        self.pageMenu.view.frame = frame_main;
        self.sideView.frame = frame_sideView;
        self.stillImageView.frame = frame_main;
        
        [UIView commitAnimations];
        
        isMenuOpen = true;
        self.pageMenu.view.hidden = YES;
    }
    
    else {
        [self closeMenu:self];
    }
}

-(IBAction)closeMenu:(id)sender {
    //Move out SideView
    [self.topBar setBackgroundColor:[UIColor blackColor]];
    CGRect frame_sideView = self.sideView.frame;
    frame_sideView = CGRectMake(0 - self.sideView.frame.size.width, 0, self.sideView.frame.size.width, self.sideView.frame.size.height);
    
    CGRect frame_main = self.pageMenu.view.frame;
    frame_main = CGRectMake(0, 50, MAIN_FULL_WIDTH, MAIN_FULL_HEIGHT);
    
    [UIView setAnimationDuration:0.2];
    [UIView beginAnimations:nil context:nil];
    
    self.pageMenu.view.frame = frame_main;
    self.sideView.frame = frame_sideView;
    self.stillImageView.frame = frame_main;
    
    [UIView commitAnimations];
    
    [self performSelector:@selector(removeStillImageView) withObject:nil afterDelay:0.2];
    
    isMenuOpen = false;
}

-(void)removeStillImageView {
    [self.stillImageView removeFromSuperview];
    self.pageMenu.view.hidden = NO;
    [self.topBar setBackgroundColor:[UIColor blackColor]];
    [self.stillImageViewButton removeFromSuperview];
}

- (UIImage *)imageByRenderingView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

-(IBAction)logOut:(id)sender {
    
    NSLog(@"Logged Out");
    
    [[ContextIOAPIInformation getAPIClient] clearCredentials];
    LoginViewController *loginVC = (LoginViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"loginVC"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)showComposeVC:(id)sender {
    //    ComposeViewController *composeVC = (ComposeViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"composeVC"];
    //
    //    [self.navigationController pushViewController:composeVC animated:YES];
    
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:@""];
        [mail setMessageBody:@"" isHTML:NO];
        [mail setToRecipients:@[@""]];
        
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
        NSLog(@"This device cannot send email");
    }
    
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    if(error) NSLog(@"ERROR - mailComposeController: %@", [error localizedDescription]);
    [self dismissModalViewControllerAnimated:YES];
    return;
}


- (IBAction)dismissNotification:(id)sender {
    [self.minimalNotification dismiss];
}


#pragma mark - InboxViewControllerDelegate

-(void)noInternetConnection {
    [self.minimalNotification show];
}

-(void)errorGettingMessages:(NSString *)errorMessage {
    self.minimalNotification = [JFMinimalNotification notificationWithStyle:JFMinimalNotificationStyleWarning title:@"Error Getting Messages" subTitle:[NSString stringWithFormat:@"%@", errorMessage] dismissalDelay:1.5 touchHandler:^(void) {
        [self dismissNotification:nil];
    }];
    [self.view addSubview:self.minimalNotification];
    [self.minimalNotification show];
}




-(IBAction)topBarTouched:(id)sender {
    NSLog(@"Top Bar Touched");
    [self.inboxDelegate topBarTouched];
    [self.attachmentsDelegate topBarTouched];
    [self.photosDelegate topBarTouched];
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
