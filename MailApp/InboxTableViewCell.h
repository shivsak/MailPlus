//
//  InboxTableViewCell.h
//  MailApp
//
//  Created by Shiv Sakhuja on 8/13/15.
//  Copyright © 2015 Shiv Sakhuja. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InboxTableViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *senderLabel;
@property (strong, nonatomic) IBOutlet UILabel *subjectLabel;
@property (strong, nonatomic) IBOutlet UILabel *importantLabel;
@property (strong, nonatomic) IBOutlet UILabel *readLabel;
@property (strong, nonatomic) IBOutlet UIImageView *attachment;
@property (strong, nonatomic) IBOutlet UILabel *imageLabel;
@property (strong, nonatomic) IBOutlet UIImageView *contactImageView;

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet NSString *senderName;
@property (strong, nonatomic) IBOutlet NSString *senderEmail;

@property (strong, nonatomic) IBOutlet NSString *messageID;

@end
