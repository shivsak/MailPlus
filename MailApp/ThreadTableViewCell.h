//
//  ThreadTableViewCell.h
//  MailApp
//
//  Created by Shiv Sakhuja on 8/13/15.
//  Copyright © 2015 Shiv Sakhuja. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThreadTableViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *senderLabel;
@property (strong, nonatomic) IBOutlet UILabel *subjectLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateTimeLabel;

@property (strong, nonatomic) IBOutlet UILabel *readLabel;
@property (strong, nonatomic) IBOutlet UIImageView *attachment;

@property (strong, nonatomic) IBOutlet UIView *leftSidebarView;
@property (strong, nonatomic) IBOutlet UIView *rightSidebarView;

@property (strong, nonatomic) NSString *messageID;

@end
