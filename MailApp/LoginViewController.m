//
//  LoginViewController.m
//  MailApp
//
//  Created by Shiv Sakhuja on 8/25/15.
//  Copyright © 2015 Shiv Sakhuja. All rights reserved.
//

#import "LoginViewController.h"
#import "BaseViewController.h"
#import "ContextIOAPIInformation.h"
#import "IntroViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBar];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0]];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.1 green:0.1 blue:0.2 alpha:1] CGColor], (id)[[UIColor colorWithRed:0.1 green:0.3 blue:0.4 alpha:1] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    
    
    if (![ContextIOAPIInformation getAPIClient].isAuthorized) {
        loginButton.hidden = NO;
        NSLog(@"API Client: %@", [ContextIOAPIInformation getAPIClient]);
        CIOAuthViewController *authController = (CIOAuthViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"authVC"];
        authController = [[CIOAuthViewController alloc] initWithAPIClient:[ContextIOAPIInformation getAPIClient] allowCancel:NO];
        
        authController.delegate = self;
        //        UINavigationController *authNavController = [[UINavigationController alloc] initWithRootViewController:authController];
        authController.navController  = self.navigationController;
        
        [self.navigationController pushViewController:authController animated:YES];
        
        return;
    }
    
    else {
        [self moveToBaseVC];
    }

    
}

-(BOOL)hasAppOpenedBefore {
    NSString *hasOpenedBefore = [[NSUserDefaults standardUserDefaults] objectForKey:@"hasOpenedBefore"];
    if ([hasOpenedBefore isEqualToString:@"YES"]) {
        return YES;
    }
    else {
        return NO;
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController popToRootViewControllerAnimated:NO];
    self.navigationController.navigationBarHidden = YES;
    //AuthVC
    
    if ([self hasAppOpenedBefore]) {
        NSLog(@"App has opened before");
    }
    else {
        NSLog(@"App hasn't opened before");
        IntroViewController *introVC = (IntroViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"introVC"];
        [self.navigationController presentViewController:introVC animated:YES completion:nil];
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"hasOpenedBefore"];
    }

    
    plusLabelBackground.backgroundColor = [UIColor colorWithRed:0.765 green:0.086 blue:0.486 alpha:0];
//    CAGradientLayer *plusGradient = [CAGradientLayer layer];
//    plusGradient.frame = plusLabelBackground.bounds;
//    plusGradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.765 green:0.086 blue:0.486 alpha:1] CGColor], (id)[[UIColor colorWithRed:0.533 green:0.322 blue:0.5 alpha:1] CGColor], nil];
//    [plusLabelBackground.layer insertSublayer:plusGradient atIndex:0];
    
//    [plusLabelBackground.layer setCornerRadius:6.0f];
//    [plusLabelBackground.layer setBorderColor:[UIColor whiteColor].CGColor];
//    [plusLabelBackground.layer setBorderWidth:1.0f];


    
    
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}


-(void)setupNavigationBar {
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.2 alpha:1]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController setTitle:@"MailApp"];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor whiteColor],
                                                                     NSForegroundColorAttributeName,
                                                                     [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0], NSFontAttributeName, nil]];
    
}


-(IBAction)loginWithGmail:(id)sender {
    NSLog(@"Login Button Pressed. API Client: %@", [ContextIOAPIInformation getAPIClient]);
    CIOAuthViewController *authController = (CIOAuthViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"authVC"];
    authController = [[CIOAuthViewController alloc] initWithAPIClient:[ContextIOAPIInformation getAPIClient] allowCancel:NO];
    
    authController.delegate = self;
    //        UINavigationController *authNavController = [[UINavigationController alloc] initWithRootViewController:authController];
    authController.navController  = self.navigationController;
    
    [self.navigationController pushViewController:authController animated:YES];
    
    return;
    
}


#pragma mark - CIOAuthViewControllerDelegate

- (void)userCompletedLogin {
    [self moveToBaseVC];
    
}

- (void)userCancelledLogin {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)moveToBaseVC {
    NSLog(@"LoginVC API Client: %@", [ContextIOAPIInformation getAPIClient].accountID);
//    BaseViewController *baseVC = (BaseViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"baseVC"];
    [self performSegueWithIdentifier:@"showMainNavController" sender:self];
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
