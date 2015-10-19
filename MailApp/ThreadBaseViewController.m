//
//  ThreadBaseViewController.m
//  MailApp
//
//  Created by Shiv Sakhuja on 8/18/15.
//  Copyright © 2015 Shiv Sakhuja. All rights reserved.
//

#import "ThreadBaseViewController.h"
#import "ThreadViewController.h"
#import "PhotosViewController.h"
#import "AttachmentsViewController.h"


@interface ThreadBaseViewController ()

@end

@implementation ThreadBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupPagingMenu];
    [self setupNavigationBar];
    [self.navigationController setNavigationBarHidden:NO];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:1] CGColor], (id)[[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    self.userNameLabel.text = [self.senderName uppercaseString];
    self.userEmailLabel.text = [self.senderEmail uppercaseString];
    self.userImageLabel.text = [[self getUserImageLabelTextForName:self.senderName withEmail:self.senderEmail] uppercaseString];
    
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [self.navigationController setNavigationBarHidden:NO];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupNavigationBar {
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBarTintColor:[UIColor blackColor]];
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
    [self.navigationController setTitle:@"MailApp"];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor whiteColor],
                                                                     NSForegroundColorAttributeName,
                                                                     [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0], NSFontAttributeName, nil]];
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
    
    ThreadViewController *threadController = (ThreadViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"threadVC"];
    threadController.title = @"MESSAGES";
    threadController.navController = self.navigationController;
    threadController.baseHeaderView = self.headerView;
    threadController.senderEmail = self.senderEmail;
    threadController.baseView = self.baseView;
    threadController.baseUserMessagesCount = self.userCountLabel;
    threadController.senderName = self.senderName;
    [controllerArray addObject:threadController];
    
    AttachmentsViewController *attachmentsController = (AttachmentsViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"attachmentsVC"];
    attachmentsController.title = @"ATTACHMENTS";
    attachmentsController.senderEmail = self.senderEmail;
    [controllerArray addObject:attachmentsController];
    
    PhotosViewController *photosController = (PhotosViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"photosVC"];
    photosController.title = @"PHOTOS";
    photosController.senderEmail = self.senderEmail;
    [controllerArray addObject:photosController];
    
    // Customize page menu to your liking (optional) or use default settings by sending nil for 'options' in the init
    // Example:
    //    NSDictionary *parameters = @{CAPSPageMenuOptionMenuItemSeparatorWidth: @(4.3),
    //                                 CAPSPageMenuOptionUseMenuLikeSegmentedControl: @(YES),
    //                                 CAPSPageMenuOptionMenuItemSeparatorPercentageHeight: @(0.1)
    //                                 };
    
    NSDictionary *parameters = @{
                                 CAPSPageMenuOptionScrollMenuBackgroundColor: [UIColor blackColor],
                                 CAPSPageMenuOptionViewBackgroundColor: [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:0],
                                 CAPSPageMenuOptionSelectionIndicatorColor: [UIColor colorWithRed:1 green:0.2 blue:0.3 alpha:0],
                                 CAPSPageMenuOptionBottomMenuHairlineColor: [UIColor clearColor],
                                 CAPSPageMenuOptionMenuItemSeparatorColor: [UIColor clearColor],
                                 CAPSPageMenuOptionMenuItemSeparatorWidth: @(4.0f),
                                 CAPSPageMenuOptionMenuItemWidth: @(100.0),
                                 CAPSPageMenuOptionUnselectedMenuItemLabelColor: [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8],
                                 CAPSPageMenuOptionSelectedMenuItemLabelColor: [UIColor colorWithRed:1 green:1 blue:1 alpha:1],
                                 CAPSPageMenuOptionMenuItemFont: [UIFont fontWithName:@"Avenir-Medium" size:13.0],
                                 CAPSPageMenuOptionMenuHeight: @(40.0),
                                 CAPSPageMenuOptionMenuItemWidth: @(90.0),
                                 CAPSPageMenuOptionCenterMenuItems: @(YES)
                                 };
    
    
    // Initialize page menu with controller array, frame, and optional parameters
    self.pageMenu = [[CAPSPageMenu alloc] initWithViewControllers:controllerArray frame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height) options:parameters];
    
    // Lastly add page menu as subview of base view controller view
    // or use pageMenu controller in you view hierachy as desired
    [self.baseView addSubview:self.pageMenu.view];
}

-(NSString *)getUserImageLabelTextForName:(NSString *)senderName withEmail:(NSString *)senderEmail {
    //Image Label Text
    NSArray *senderNameArray = [senderName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (senderNameArray.count > 1) {
        return [NSString stringWithFormat:@"%@%@", [senderNameArray[0] substringToIndex:1], [senderNameArray[1] substringToIndex:1]];
    }
    else if (!(senderName.length == 0)) {
        return [senderName substringToIndex:1];
    }
    else {
        return [senderEmail substringToIndex:1];
    }
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
