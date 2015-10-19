//
//  ImageViewController.h
//  MailApp
//
//  Created by Shiv Sakhuja on 8/29/15.
//  Copyright © 2015 Shiv Sakhuja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JFMinimalNotification.h"

@interface ImageViewController : UIViewController

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *messageID;
@property (strong, nonatomic) NSString *fileID;
@property (strong, nonatomic) NSString *imageName;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *imageNameLabel;

@property (strong, nonatomic) JFMinimalNotification *minimalNotification;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;


-(IBAction)viewMessage:(id)sender;
-(IBAction)showShareSheet:(id)sender;

@end
