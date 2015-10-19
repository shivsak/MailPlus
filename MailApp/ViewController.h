//
//  ViewController.h
//  MailApp
//
//  Created by Shiv Sakhuja on 8/13/15.
//  Copyright © 2015 Shiv Sakhuja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InboxDelegate.h"
#import "BaseViewControllerDelegate.h"

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, BaseViewControllerDelegate>

@property (weak) id <InboxDelegate> delegate;

@property (strong, nonatomic) IBOutlet UITableView *inboxTableView;

@property (strong, nonatomic) NSMutableArray *inboxData;
@property (strong, nonatomic) NSMutableArray *searchData;
@property (strong, nonatomic) NSMutableArray *messagesData;
@property (strong, nonatomic) NSMutableArray *searchResults;

@property (strong, nonatomic) NSString *selectedThreadID;
@property (strong, nonatomic) NSString *selectedFromEmail;

@property (strong, nonatomic) NSString *filter;

@property (strong, nonatomic) UINavigationController *navController;

-(IBAction)tabButtonPressed:(id)sender;

-(IBAction)showComposeVC:(id)sender;

-(void)applyFilter;
-(void)setupGradient;

@end

