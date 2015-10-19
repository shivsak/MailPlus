//
//  IntroViewController.m
//  MailApp
//
//  Created by Shiv Sakhuja on 9/1/15.
//  Copyright © 2015 Shiv Sakhuja. All rights reserved.
//

#import "IntroViewController.h"

@interface IntroViewController ()

@end

@implementation IntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self showSecondView:nil];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

-(IBAction)showFirstView:(id)sender {
    CGRect firstView_frame = firstView.frame;
    CGRect secondView_frame = secondView.frame;
    
    firstView_frame.origin = CGPointMake(self.view.frame.origin.x, 0);
    secondView_frame.origin = CGPointMake(self.view.frame.size.width, 0);

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    firstView.frame = firstView_frame;
    secondView.frame = secondView_frame;
    
    [UIView commitAnimations];
}

-(IBAction)showSecondView:(id)sender {
    CGRect firstView_frame = firstView.frame;
    CGRect secondView_frame = secondView.frame;
    
    firstView_frame.origin = CGPointMake(-self.view.frame.size.width, 0);
    secondView_frame.origin = CGPointMake(self.view.frame.origin.x, 0);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    firstView.frame = firstView_frame;
    secondView.frame = secondView_frame;
    
    [UIView commitAnimations];
}

-(IBAction)finishIntro:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"hasOpenedBefore"];
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
