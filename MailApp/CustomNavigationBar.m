//
//  CustomNavigationBar.m
//  MailApp
//
//  Created by Shiv Sakhuja on 8/13/15.
//  Copyright © 2015 Shiv Sakhuja. All rights reserved.
//

#import "CustomNavigationBar.h"

const CGFloat extraHeight = 15.0f;

@implementation CustomNavigationBar

- (CGSize)sizeThatFits:(CGSize)size {
    
    CGSize amendedSize = [super sizeThatFits:size];
    amendedSize.height += extraHeight;
    
    return amendedSize;
}


@end