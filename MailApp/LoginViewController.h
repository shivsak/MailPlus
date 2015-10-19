//
//  LoginViewController.h
//  MailApp
//
//  Created by Shiv Sakhuja on 8/25/15.
//  Copyright © 2015 Shiv Sakhuja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CIOAuthViewController.h"
#import "BorderedButton.h"

@interface LoginViewController : UIViewController <CIOAuthViewController> {
    IBOutlet BorderedButton *loginButton;
    IBOutlet UIView *plusLabelBackground;
}

-(IBAction)loginWithGmail:(id)sender;

@end
