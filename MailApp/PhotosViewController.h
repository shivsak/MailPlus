//
//  PhotosViewController.h
//  MailApp
//
//  Created by Shiv Sakhuja on 8/16/15.
//  Copyright © 2015 Shiv Sakhuja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewControllerDelegate.h"

@interface PhotosViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, BaseViewControllerDelegate>


@property (strong, nonatomic) NSArray *attachmentsArray;
@property (strong, nonatomic) NSMutableArray *photoIDsArray;
@property (strong, nonatomic) NSMutableArray *photosCache;

@property (strong, nonatomic) NSString *senderEmail;
@property NSInteger *numberOfPhotos;

@property (strong, nonatomic) UINavigationController *navController;

@property (strong, nonatomic) IBOutlet UICollectionView *photosCollectionView;


@end
