//
//  HighlightsViewController.h
//  MailApp
//
//  Created by Shiv Sakhuja on 8/20/15.
//  Copyright © 2015 Shiv Sakhuja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DraggableViewBackground.h"
#import "DraggableView.h"
#import "JFMinimalNotification.h"

@interface HighlightsViewController : UIViewController <DraggableViewBackgroundDelegate>

@property (strong, nonatomic) IBOutlet UIView *cardView;

@property (strong, nonatomic) NSMutableArray *importantMails;

@property (strong, nonatomic) NSString *dateAfter;

@property (strong, nonatomic) JFMinimalNotification *minimalNotification;

@end
