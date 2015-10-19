//
//  ComposeViewController.m
//  MailApp
//
//  Created by Shiv Sakhuja on 8/16/15.
//  Copyright © 2015 Shiv Sakhuja. All rights reserved.
//

#import "ComposeViewController.h"

@interface ComposeViewController ()

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self setupTextFields];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupNavigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden {
    return NO;
}

-(void)setupNavigationBar {
    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithRed:1 green:0.2 blue:0.3 alpha:1.0]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:1 green:0.2 blue:0.3 alpha:1.0]];
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor whiteColor],
                                                                     NSForegroundColorAttributeName,
                                                                     [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0], NSFontAttributeName, nil]];
}

-(void)setupTextFields {
    self.toField.floatLabelActiveColor = [UIColor colorWithRed:1 green:0.2 blue:0.35 alpha:1];
    self.subjectField.floatLabelActiveColor = [UIColor colorWithRed:1 green:0.2 blue:0.35 alpha:1];
}

-(IBAction)returnKeyPressed:(id)sender {
    [sender resignFirstResponder];
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
