//
//  ThreadBaseViewController.h
//  MailApp
//
//  Created by Shiv Sakhuja on 8/18/15.
//  Copyright © 2015 Shiv Sakhuja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CAPSPageMenu.h"

@interface ThreadBaseViewController : UIViewController {
    
}

@property (nonatomic, strong) NSString *senderEmail;
@property (nonatomic, strong) NSString *senderName;

@property (nonatomic, strong) IBOutlet UIView *baseView;

@property (strong, nonatomic) IBOutlet UIView *headerView;

@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *userCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *userEmailLabel;
@property (strong, nonatomic) IBOutlet UILabel *userImageLabel;

@property (nonatomic, strong) IBOutlet CAPSPageMenu *pageMenu;

@end
