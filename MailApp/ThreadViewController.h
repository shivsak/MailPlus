//
//  ThreadViewController.h
//  MailApp
//
//  Created by Shiv Sakhuja on 8/13/15.
//  Copyright © 2015 Shiv Sakhuja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CAPSPageMenu.h"

@interface ThreadViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate> {
    float height;
}

@property (strong, nonatomic) IBOutlet UITableView *threadTableView;

@property (strong, nonatomic) NSMutableArray *messagesData;
@property (strong, nonatomic) NSMutableArray *threadData;

@property (nonatomic, strong) NSString *senderName;
@property (strong, nonatomic) NSString *senderEmail;
@property (strong, nonatomic) NSString *selectedMessageID;

@property (strong, nonatomic) IBOutlet UIView *baseHeaderView;

@property (strong, nonatomic) IBOutlet UILabel *baseUserMessagesCount;

@property (strong, nonatomic) IBOutlet UIView *baseView;

@property (strong, nonatomic) UINavigationController *navController;

-(IBAction)showComposeVC:(id)sender;

@end
