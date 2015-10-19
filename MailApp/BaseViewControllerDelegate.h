//
//  BaseViewControllerDelegate.h
//  MailApp
//
//  Created by Shiv Sakhuja on 9/1/15.
//  Copyright © 2015 Shiv Sakhuja. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BaseViewController;

@protocol BaseViewControllerDelegate <NSObject>

-(void)topBarTouched;

@end