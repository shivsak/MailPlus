//
//  BaseViewController.h
//  MailApp
//
//  Created by Shiv Sakhuja on 8/17/15.
//  Copyright © 2015 Shiv Sakhuja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CAPSPageMenu.h"
#import <MessageUI/MessageUI.h>
#import "JFMinimalNotification.h"
#import "InboxDelegate.h"
#import "BaseViewControllerDelegate.h"

@interface BaseViewController : UIViewController <MFMailComposeViewControllerDelegate, InboxDelegate> {
    //SideView Buttons
    
    IBOutlet UIButton *draftsButton;
    IBOutlet UIButton *highlightsButton;
    IBOutlet UIButton *importantButton;
    IBOutlet UIButton *allButton;
    IBOutlet UIButton *sentButton;
}

@property (weak) id <BaseViewControllerDelegate> inboxDelegate;
@property (weak) id <BaseViewControllerDelegate> attachmentsDelegate;
@property (weak) id <BaseViewControllerDelegate> photosDelegate;

@property (nonatomic, strong) IBOutlet CAPSPageMenu *pageMenu;
@property (nonatomic, strong) IBOutlet UIView *pageMenuContainer;

@property (nonatomic, strong) IBOutlet UIView *sideView;

@property (nonatomic, strong) NSString *filter;

@property (nonatomic, strong) IBOutlet UIView *topBar;
@property (nonatomic, strong) IBOutlet UILabel *topBarTitle;
@property (nonatomic, strong) IBOutlet UIImageView *stillImageView;

@property (nonatomic, strong) IBOutlet UIView *stillView;

@property (strong, nonatomic) JFMinimalNotification *minimalNotification;

@property (nonatomic, strong) IBOutlet UIButton *stillImageViewButton;


-(IBAction)showSideView:(id)sender;

-(IBAction)showComposeVC:(id)sender;

-(IBAction)logOut:(id)sender;



@end
