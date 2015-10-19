//
//  ContextIOAPIInformation.h
//  MailApp
//
//  Created by Shiv Sakhuja on 8/25/15.
//  Copyright © 2015 Shiv Sakhuja. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CIOAuthViewController.h"

@interface ContextIOAPIInformation : NSObject

+(CIOAPISession *)getAPIClient;
+(void)setAPIClient:(CIOAPISession *)client;

@end
