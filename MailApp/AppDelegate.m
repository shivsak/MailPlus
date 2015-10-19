//
//  AppDelegate.m
//  MailApp
//
//  Created by Shiv Sakhuja on 8/13/15.
//  Copyright © 2015 Shiv Sakhuja. All rights reserved.
//

#import "AppDelegate.h"
#import <CIOAPIClient/CIOAPISession.h>
#import "LoginViewController.h"
#import "ContextIOAPIInformation.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>


@interface AppDelegate ()

@end

@implementation AppDelegate

//#error Please enter your Context.IO API credentials below and comment out this line.
static NSString * const kContextIOConsumerKey = @"*******";
static NSString * const kContextIOConsumerSecret = @"*************";
// You didn't actually think I'd put up my credentials online, did you?


- (UIStoryboard *)grabStoryboard {

    UIStoryboard *storyboard;

    // detect the height of our screen
    int width = [UIScreen mainScreen].bounds.size.width;

    if (width == 320) {
        storyboard = [UIStoryboard storyboardWithName:@"Main-iPhone5" bundle:nil];
        // NSLog(@"Device has a 4-inch Display.");
    }
    else if (width == 375) {
        storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        // NSLog(@"Device has a 4.7-inch Display.");
    }
    else {
        storyboard = [UIStoryboard storyboardWithName:@"Main-iPhone6Plus" bundle:nil];
        // NSLog(@"Device has a 5.5-inch Display.");
    }

    return storyboard;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [Fabric with:@[[Crashlytics class]]];

    UIStoryboard *storyboard = [self grabStoryboard];

    // show the storyboard
    self.window.rootViewController = [storyboard instantiateInitialViewController];
    [self.window makeKeyAndVisible];

    CIOAPISession *client = [[CIOAPISession alloc] initWithConsumerKey:kContextIOConsumerKey consumerSecret:kContextIOConsumerSecret];

    LoginViewController *controller = (LoginViewController *)[storyboard instantiateViewControllerWithIdentifier: @"loginVC"];
    [ContextIOAPIInformation setAPIClient:client];

    UINavigationController *rootNavController = [[UINavigationController alloc] initWithRootViewController:controller];
    self.window.rootViewController = rootNavController;


    //Customize Navigation Bar
//    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:1 green:0.2 blue:0.3 alpha:1]];
//    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
//    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
//                                                          [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0], NSForegroundColorAttributeName,
//                                                          [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0], NSFontAttributeName, nil]];
//

    return YES;
}


-(BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
