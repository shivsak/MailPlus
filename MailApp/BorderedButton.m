//
//  BorderedButton.m
//  MailApp
//
//  Created by Shiv Sakhuja on 8/16/15.
//  Copyright © 2015 Shiv Sakhuja. All rights reserved.
//

#import "BorderedButton.h"

@implementation BorderedButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib
{
    self.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
    self.layer.cornerRadius = self.frame.size.height/2;
    self.layer.borderColor = self.titleLabel.textColor.CGColor;
    self.layer.borderWidth = 1.0f;
    self.layer.masksToBounds = YES;
}

-(void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    if (!enabled) {
        self.alpha = 0.5;
    }
    else {
        self.alpha = 1.0;
    }
}

@end
