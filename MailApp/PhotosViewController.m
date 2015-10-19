//
//  PhotosViewController.m
//  MailApp
//
//  Created by Shiv Sakhuja on 8/16/15.
//  Copyright © 2015 Shiv Sakhuja. All rights reserved.
//

#import "PhotosViewController.h"
#import "PhotosCollectionReusableView.h"
#import "ContextIOAPIInformation.h"
#import "ImageViewController.h"
#import "SVPullToRefresh.h"

@interface PhotosViewController ()

@end

@implementation PhotosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //    [self getData];
    self.photoIDsArray = [[NSMutableArray alloc] init];
    self.photosCache = [[NSMutableArray alloc] init];
    self.numberOfPhotos = 0;
    [self loadData];
    
    [self setupCollectionView];
    
    NSLog(@"PhotosVC");
    if ([self.senderEmail isEqualToString:@"-99"]) {
        //No User ID, Show All Photos
        [self getAttachments];
    }
    else {
        [self getAttachmentsFromUserID:self.senderEmail];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupNavigationBar];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}


-(void)setupNavigationBar {
    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithRed:0.9608 green:0.9608 blue:0.9608 alpha:0]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.9608 green:0.9608 blue:0.9608 alpha:0]];
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:0.8 green:0.2 blue:0.3 alpha:1.0]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor darkGrayColor],
                                                                     NSForegroundColorAttributeName,
                                                                     [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0], NSFontAttributeName, nil]];
}

-(void)setupCollectionView {
    [self.photosCollectionView addPullToRefreshWithActionHandler:^{
        [self getAttachmentsWithOffset:0];
    }];
    [self.photosCollectionView.pullToRefreshView setArrowColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.2 alpha:0.8]];
    [self.photosCollectionView.pullToRefreshView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.photosCollectionView.pullToRefreshView setTextColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.2 alpha:0.8]];
}


#pragma mark - Collection View Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.numberOfPhotos;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"PhotosCell";
    
    PhotosCollectionReusableView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    if (self.photosCache[indexPath.row] != NULL) {
        cell.imageView.image = self.photosCache[indexPath.row];
    }
    else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //Do background work
            //            NSLog(@"getting Image at Index %ld", indexPath.row);
            if (self.attachmentsArray != NULL) {
                [self getImageForCellAtIndexPath:indexPath];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //Update UI
                
            });
        });
    }
    
    
    return cell;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"Cell at index %ld Selected", indexPath.row);
    PhotosCollectionReusableView *cell = (PhotosCollectionReusableView *) [self.photosCollectionView cellForItemAtIndexPath:indexPath];
    ImageViewController *imageVC = (ImageViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"imageVC"];
    imageVC.image = cell.imageView.image;
    imageVC.fileID = self.photoIDsArray[indexPath.row][@"file_id"];
    imageVC.imageName = self.photoIDsArray[indexPath.row][@"file_name"];
    imageVC.messageID = self.photoIDsArray[indexPath.row][@"message_id"];
    [self.navController pushViewController:imageVC animated:YES];
    
    
}

-(NSUInteger)numberOfColumnsInCollectionView:(UICollectionView *)collectionView {
    return 3;
}


-(void)getAttachmentsFromUserID:(NSString *)userID {
    NSLog(@"API Client: %@", [ContextIOAPIInformation getAPIClient]);
    NSDictionary *params = @{@"limit": @(100)};
    [[[ContextIOAPIInformation getAPIClient] getFilesForContactWithEmail:userID params:params]
     executeWithSuccess:^(NSArray *response) {
         self.attachmentsArray = [NSArray arrayWithArray:response];
         NSLog(@"Attachments downloaded");
         //         NSLog(@"Attachments: %@", self.attachmentsArray);
         [self getNumberOfPhotos];
         [self.photosCollectionView reloadData];
     } failure:^(NSError *error) {
         NSLog(@"error getting attachments: %@", error.localizedDescription);
     }];
    
    
}


-(void)getAttachments {
    [self getAttachmentsWithOffset:0];
    
}

-(void)getAttachmentsWithOffset:(int)offset {
    NSLog(@"API Client: %@", [ContextIOAPIInformation getAPIClient]);
    NSDictionary *params = @{@"limit": @(100),
                             @"offset": @(offset)
                             };
    [[[ContextIOAPIInformation getAPIClient] getFilesWithParams:params]
     executeWithSuccess:^(NSArray *responseDict) {
         self.attachmentsArray = responseDict;
         NSLog(@"Attachments downloaded");
         [self getNumberOfPhotos];
         [self.photosCollectionView.pullToRefreshView stopAnimating];
         [self.photosCollectionView reloadData];
     } failure:^(NSError *error) {
         NSLog(@"error getting messages: %@", error);
     }];
    
    
}

-(void)getNumberOfPhotos {
    int counter = 0;
    while (counter < self.attachmentsArray.count) {
        if ([[[self.attachmentsArray objectAtIndex:counter] objectForKey:@"type"] rangeOfString:@"image" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [self.photoIDsArray addObject:[self.attachmentsArray objectAtIndex:counter]];
        }
        counter++;
        NSLog(@"number of photos running");
    }
    NSLog(@"photoIDsArray: %@", self.photoIDsArray);
    self.numberOfPhotos = self.photoIDsArray.count;
}



-(void)getImageForCellAtIndexPath:(NSIndexPath *)indexPath {
    NSString *attachmentID = [[self.photoIDsArray objectAtIndex:indexPath.row] objectForKey:@"file_id"];
    NSLog(@"AttachmentID: %@", attachmentID);
    NSLog(@"getting Images for Cell at Index Path %ld", indexPath.row);
    
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *fileURL = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@", attachmentID]];
    if ([fileURL checkResourceIsReachableAndReturnError:nil]) {
        [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
    }
    [[ContextIOAPIInformation getAPIClient] downloadRequest:[[ContextIOAPIInformation getAPIClient] downloadContentsOfFileWithID:attachmentID]
                                                  toFileURL:fileURL
                                                    success:^{
                                                        
                                                        NSLog(@"File downloaded to %@:", [fileURL path]);
                                                        PhotosCollectionReusableView *cell = [self.photosCollectionView cellForItemAtIndexPath:indexPath];
                                                        UIImage *image = [UIImage imageWithContentsOfFile:[fileURL path]];
                                                        NSLog(@"Image: %@", image);
                                                        [self.photosCache addObject:image];
                                                        cell.imageView.image = image;
                                                        [self saveData];
                                                        
                                                    }
                                                    failure:^(NSError *error) {
                                                        NSLog(@"Download error: %@", error);
                                                    }
                                                   progress:^(int64_t bytesRead, int64_t totalBytesRead, int64_t totalBytesExpected){
                                                       //                               NSLog(@"Download progress: %0.2f%%", ((double)totalBytesExpected / (double)totalBytesRead) * 100);
                                                   }];
}





#pragma mark - Save Photos Array

-(void)saveData{
    [[NSUserDefaults standardUserDefaults] setObject:self.photosCache forKey:@"photosCache"];
}

-(void)loadData {
    self.photosCache = [[NSUserDefaults standardUserDefaults] objectForKey:@"photosCache"];
    if (self.photosCache != NULL)
    {
        [self.photosCollectionView reloadData];
    }
}


#pragma mark - BaseViewControllerDelegate

-(void)topBarTouched {
    if ([self.photosCollectionView numberOfSections] > 0)
    {
        NSIndexPath* top = [NSIndexPath indexPathForItem:0 inSection:0];
        [self.photosCollectionView scrollToItemAtIndexPath:top atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    }
}



/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
