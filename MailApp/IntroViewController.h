//
//  IntroViewController.h
//  MailApp
//
//  Created by Shiv Sakhuja on 9/1/15.
//  Copyright © 2015 Shiv Sakhuja. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroViewController : UIViewController {
    IBOutlet UIView *firstView;
    IBOutlet UIView *secondView;
}

-(IBAction)showFirstView:(id)sender;
-(IBAction)showSecondView:(id)sender;
-(IBAction)finishIntro:(id)sender;

@end
