//
//  AttachmentsViewController.h
//  MailApp
//
//  Created by Shiv Sakhuja on 8/16/15.
//  Copyright © 2015 Shiv Sakhuja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
#import "BaseViewControllerDelegate.h"


@interface AttachmentsViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, QLPreviewControllerDelegate, QLPreviewControllerDataSource, UITextFieldDelegate, BaseViewControllerDelegate>

@property (strong, nonatomic) NSArray *attachmentsArray;
@property (strong, nonatomic) NSMutableArray *displayFilesArray;
@property (strong, nonatomic) NSMutableArray *searchFilesArray;

@property BOOL isDownloaded;
@property (strong, nonatomic) NSString *selectedFileID;
@property (strong, nonatomic) NSURL *fileURL;

@property (strong, nonatomic) IBOutlet UITextField *searchTextField;

@property (strong, nonatomic) QLPreviewController *previewController;

@property (strong, nonatomic) UINavigationController *navController;

@property (strong, nonatomic) NSString *senderEmail;
@property (strong, nonatomic) IBOutlet UICollectionView *attachmentsCollectionView;

@end
