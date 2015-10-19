//
//  ComposeViewController.h
//  MailApp
//
//  Created by Shiv Sakhuja on 8/16/15.
//  Copyright © 2015 Shiv Sakhuja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIFloatLabelTextField.h"
#import "CIOAuthViewController.h"
#import <MessageUI/MessageUI.h>

@interface ComposeViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property (nonatomic, retain) IBOutlet UIFloatLabelTextField *toField;
@property (nonatomic, retain) IBOutlet UIFloatLabelTextField *subjectField;

-(IBAction)returnKeyPressed:(id)sender;

@end
