//
//  InboxDelegate.h
//  MailApp
//
//  Created by Shiv Sakhuja on 9/1/15.
//  Copyright © 2015 Shiv Sakhuja. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ViewController;

@protocol InboxDelegate <NSObject>

-(void)noInternetConnection;
-(void)errorGettingMessages:(NSString *)errorMessage;

@end