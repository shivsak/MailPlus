//
//  MessageViewController.h
//  MailApp
//
//  Created by Shiv Sakhuja on 8/15/15.
//  Copyright © 2015 Shiv Sakhuja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CIOAuthViewController.h"
#import <MessageUI/MessageUI.h>
#import "JFMinimalNotification.h"
#import "BorderedButton.h"

@interface MessageViewController : UIViewController <UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIWebViewDelegate, MFMailComposeViewControllerDelegate> {
    float height;
    IBOutlet UILabel *contactImageLabel;
    
    IBOutlet UILabel *detailContactImageLabel;
    IBOutlet UILabel *detailSenderLabel;
    IBOutlet UILabel *detailSenderEmail;
    IBOutlet UILabel *detailDate;
    IBOutlet UIImageView *detailAttachmentsImage;
    IBOutlet UIButton *detailAttachmentsButton;
    
    IBOutlet BorderedButton *unsubscribeButton;
    
}

@property (strong, nonatomic) IBOutlet UITextView *messageTextView;
@property (strong, nonatomic) IBOutlet UILabel *senderLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *subjectLabel;
@property (strong, nonatomic) IBOutlet UIButton *attachments;
@property (strong, nonatomic) IBOutlet UIView *headerView;

@property (strong, nonatomic) IBOutlet UIView *messageDetailsView;
@property (strong, nonatomic) IBOutlet UIView *messageDetailsBackgroundView;

@property (strong, nonatomic) NSMutableArray *receivedArray;
@property (strong, nonatomic) IBOutlet UICollectionView *receivedCollectionView;

@property (strong, nonatomic) IBOutlet UIWebView *messageWebView;

@property (strong, nonatomic) NSDictionary *messageData;
@property (strong, nonatomic) NSString *messageID;

@property (strong, nonatomic) NSString *senderEmailID;

@property (strong, nonatomic) JFMinimalNotification *minimalNotification;

-(IBAction)showReplyVC:(id)sender;
-(IBAction)showReplyAllVC:(id)sender;
-(IBAction)showForwardVC:(id)sender;

-(IBAction)showDetails:(id)sender;
-(IBAction)hideDetails:(id)sender;

-(IBAction)showAttachments:(id)sender;

@end
