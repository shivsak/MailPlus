//
//  AttachmentsViewController.m
//  MailApp
//
//  Created by Shiv Sakhuja on 8/16/15.
//  Copyright © 2015 Shiv Sakhuja. All rights reserved.
//

#import "AttachmentsViewController.h"
#import "ContextIOAPIInformation.h"
#import "CustomAlertView.h"
#import "ImageViewController.h"
#import "SVPullToRefresh.h"

@interface AttachmentsViewController ()

@property BOOL isLoadingMoreData;
@property BOOL isSearching;
@property long loadedMessages;

@end

@implementation AttachmentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadData];
    [self setupCollectionView];
    
    self.searchFilesArray = [[NSMutableArray alloc] init];
    
    if (self.displayFilesArray == NULL) {
        self.displayFilesArray = [[NSMutableArray alloc] init];
    }
    
    self.loadedMessages = 0;
    // Do any additional setup after loading the view.
    if ([self.senderEmail isEqual:@"-99"]) {
        [self getAttachments];
    }
    
    if ([self.senderEmail isEqual:@"-95"]) {
        //Also send attachment array
        [self.attachmentsCollectionView reloadData];
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
    if ([self.attachmentsCollectionView numberOfItemsInSection:0] == 0) {
        
    }
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}


-(void)setupNavigationBar {
    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithRed:0.9608 green:0.9608 blue:0.9608 alpha:1]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.9608 green:0.9608 blue:0.9608 alpha:1]];
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:0.8 green:0.2 blue:0.3 alpha:1.0]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor darkGrayColor],
                                                                     NSForegroundColorAttributeName,
                                                                     [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0], NSFontAttributeName, nil]];
}

-(void)setupCollectionView {
    [self.attachmentsCollectionView addPullToRefreshWithActionHandler:^{
        [self getAttachmentsWithOffset:0];
    }];
    [self.attachmentsCollectionView.pullToRefreshView setArrowColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.2 alpha:0.8]];
    [self.attachmentsCollectionView.pullToRefreshView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.attachmentsCollectionView.pullToRefreshView setTextColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.2 alpha:0.8]];
}

-(void)getAttachmentsFromUserID:(NSString *)userID {
    NSLog(@"API Client: %@", [ContextIOAPIInformation getAPIClient]);
    NSDictionary *params = @{
                             @"limit": @(100),
                             @"offset": @(0)
                             };
    [[[ContextIOAPIInformation getAPIClient] getFilesForContactWithEmail:userID params:params]
     executeWithSuccess:^(NSArray *responseDict) {
         self.attachmentsArray = responseDict;
         self.displayFilesArray = [NSMutableArray arrayWithArray:self.attachmentsArray];
         NSLog(@"Attachments: %@", self.attachmentsArray);
         [self.attachmentsCollectionView reloadData];
         [self.previewController reloadData];
     } failure:^(NSError *error) {
         NSLog(@"error getting attachments: %@", error);
//         [self showErrorMessage:error.localizedDescription];
     }];
    
    
}

-(void)showErrorMessage:(NSString *)errorMessage {
//    CustomAlertView *alert = [[CustomAlertView alloc] init];
//    [alert initWithTitle:@"Error!" message:errorMessage firstButtonText:nil cancelButtonText:@"Okay" withContainer:self];
//    [alert.customAlertButtonCancel addTarget:self action:@selector(removeAlert:) forControlEvents:UIControlEventTouchUpInside];
//    [alert setTheme:4];
//    [alert.customAlertButtonCancel setBackgroundColor:[UIColor colorWithRed:0.4 green:0.8159 blue:0 alpha:1.0]];
//    [alert setPosition:0];
//    [alert showAlert];
}

-(IBAction)removeAlert:(id)sender {
    [[[sender superview] superview] removeFromSuperview];
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
         self.displayFilesArray = [NSMutableArray arrayWithArray:self.attachmentsArray];
         //         NSLog(@"Attachments: %@", self.attachmentsArray);
         
         self.loadedMessages += 100;
         
         [self saveData];
         
         if ([self.attachmentsCollectionView numberOfItemsInSection:0] < 12 && !self.isSearching) {
//             [self getAttachmentsWithOffset:self.loadedMessages];
         }
         [self.attachmentsCollectionView.pullToRefreshView stopAnimating];
         [self.attachmentsCollectionView reloadData];
         [self.previewController reloadData];
     } failure:^(NSError *error) {
         NSLog(@"error getting messages: %@", error);
         [self showErrorMessage:error.localizedDescription];
     }];
    
    
}

#pragma mark - Scroll

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    float reload_distance = 10;
    //    NSLog(@"ScrollViewDidScroll: %f", offset.y);
    if(y > h + reload_distance && !self.isLoadingMoreData) {
        NSLog(@"Loading Attachments with Offset: %ld", self.loadedMessages);
        self.isLoadingMoreData = YES;
        [self getAttachmentsWithOffset:self.loadedMessages];
    }
}


#pragma mark - Get Data

-(void)getData {
    
}



#pragma mark - Collection View Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.displayFilesArray count];
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"AttachmentsCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    //Image
    UIImageView *collectionImageView = (UIImageView *)[cell viewWithTag:99];
    
    //Name Label
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
    
    //Size Label
    UILabel *sizeLabel = (UILabel *)[cell viewWithTag:100];
    
    if (self.displayFilesArray != NULL) {
        
        //Name
        [nameLabel setText:[self.displayFilesArray[indexPath.row] objectForKey:@"file_name"]];
        
        //Fize Size
        NSString *fileSizeBytes = [self.displayFilesArray[indexPath.row] objectForKey:@"size"];
        double fileSizeKB = [fileSizeBytes doubleValue] / 1024.0;
        double fileSizeMB = fileSizeKB / 1024.0;
        double fileSizeGB = fileSizeMB / 1024.0;
        if (fileSizeGB >= 1.0) {
            sizeLabel.text = [NSString stringWithFormat:@"%.1f GB", fileSizeGB];
        }
        else if (fileSizeMB >= 1.0) {
            sizeLabel.text = [NSString stringWithFormat:@"%.1f MB", fileSizeMB];
        }
        else if (fileSizeKB >= 1.0) {
            sizeLabel.text = [NSString stringWithFormat:@"%.1f KB", fileSizeKB];
        }
        else {
            sizeLabel.text = [NSString stringWithFormat:@"%.1f Bytes", [fileSizeBytes doubleValue]];
        }
        
        
        //File Type Icon
        NSString *type = self.displayFilesArray[indexPath.row][@"type"];
        if ([type rangeOfString:@"jpg" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            collectionImageView.image = [UIImage imageNamed:@"jpeg-image.png"];
        }
        else if ([type rangeOfString:@"image" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            collectionImageView.image = [UIImage imageNamed:@"image.png"];
        }
        else if ([type rangeOfString:@"photoshop" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            collectionImageView.image = [UIImage imageNamed:@"psd.png"];
        }
        else if ([type rangeOfString:@"illustrator" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            collectionImageView.image = [UIImage imageNamed:@"ai.png"];
        }
        else if ([type rangeOfString:@"application/pdf" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            collectionImageView.image = [UIImage imageNamed:@"pdf.png"];
        }
        else if ([type rangeOfString:@"wordprocessing" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            collectionImageView.image = [UIImage imageNamed:@"document.png"];
        }
        else if ([type rangeOfString:@"powerpoint" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            collectionImageView.image = [UIImage imageNamed:@"powerpoint.png"];
        }
        else if ([type rangeOfString:@"keynote" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            collectionImageView.image = [UIImage imageNamed:@"keynote.png"];
        }
        else if ([type rangeOfString:@"mp3" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            collectionImageView.image = [UIImage imageNamed:@"audio-mp3.png"];
        }
        else {
            collectionImageView.image = [UIImage imageNamed:@"generic-doc.png"];
        }
        
        NSArray *fileNameStructure = self.displayFilesArray[indexPath.row][@"file_name_structure"];
        for (NSArray *structureArray in fileNameStructure) {
            if ([structureArray containsObject:@".ai"]) {
                collectionImageView.image = [UIImage imageNamed:@"ai.png"];
            }
        }
        
        
        
    }
    
    return cell;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //Get File from Index Path
    self.selectedFileID = self.displayFilesArray[indexPath.row][@"file_id"];
    NSString *fileName = self.displayFilesArray[indexPath.row][@"file_name"];
    [self downloadContentsOfFileWithID:self.selectedFileID fileName:fileName];
    
    NSString *type = self.displayFilesArray[indexPath.row][@"type"];
    if ([type rangeOfString:@"image" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        ImageViewController *imageVC = (ImageViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"imageVC"];
        imageVC.image = nil;
        imageVC.fileID = self.selectedFileID;
        imageVC.imageName = self.displayFilesArray[indexPath.row][@"file_name"];
        imageVC.messageID = self.displayFilesArray[indexPath.row][@"message_id"];
        [self.navController pushViewController:imageVC animated:YES];
    }
    else {
        //Present Preview Controller
        self.previewController = [[QLPreviewController alloc] init];
        self.previewController.delegate = self;
        self.previewController.dataSource = self;
        [self.navController presentViewController:self.previewController animated:YES completion:nil];
        [self.previewController.navigationItem setRightBarButtonItem:nil];
    }
    
    
}

//-(NSUInteger)numberOfColumnsInCollectionView:(UICollectionView *)collectionView {
//    return 3;
//}



-(void)downloadContentsOfFileWithID:(NSString *)fileID fileName:(NSString *)fileName {
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    NSString *fileIDShortened = [fileID substringToIndex:3];
    NSURL *fileURL = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", fileName, fileIDShortened]];
    if ([fileURL checkResourceIsReachableAndReturnError:nil]) {
        [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
    }
    NSLog(@"Download Request for File with ID: %@", self.selectedFileID);
    [[ContextIOAPIInformation getAPIClient] downloadRequest:[[ContextIOAPIInformation getAPIClient] downloadContentsOfFileWithID:fileID]
                                                  toFileURL:fileURL
                                                    success:^{
                                                        self.isDownloaded = YES;
                                                        self.fileURL = fileURL;
                                                        [self.previewController reloadData];
                                                    }
                                                    failure:^(NSError *error) {
                                                        NSLog(@"Download error: %@", error);
                                                    }
                                                   progress:^(int64_t bytesRead, int64_t totalBytesRead, int64_t totalBytesExpected){
                                                       NSLog(@"Download progress: %0.2f%%", ((double)totalBytesExpected / (double)totalBytesRead) * 100);
                                                   }];
    
}



#pragma mark - QLPreviewController

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    if (self.isDownloaded) {
        return 1;
    }
    else {
        return 0;
    }
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return self.fileURL;
}

#pragma mark - Keyboard

-(IBAction)returnKeyPressed:(id)sender {
    [sender resignFirstResponder];
    [self.searchFilesArray removeAllObjects];
    
    self.isSearching = YES;
    NSString *searchQuery = self.searchTextField.text;
    NSLog(@"Attachments Search Query: %@", searchQuery);
    
    if (searchQuery.length == 0) {
        [self.attachmentsCollectionView reloadData];;
        [self textFieldShouldClear:self.searchTextField];
    }
    else {
        
        for (int i=0; i<[self.displayFilesArray count]; i++) {
            NSString *senderName = [[[[self.displayFilesArray objectAtIndex:i] objectForKey:@"addresses"] objectForKey:@"from"] objectForKey:@"name"];
            NSString *senderEmail = [[[[self.displayFilesArray objectAtIndex:i] objectForKey:@"addresses"] objectForKey:@"from"] objectForKey:@"email"];
            NSString *subject = [[self.displayFilesArray objectAtIndex:i] objectForKey:@"subject"];
            NSString *fileName = [[self.displayFilesArray objectAtIndex:i] objectForKey:@"file_name"];
            
            BOOL searchCondition = [senderName rangeOfString:searchQuery options:NSCaseInsensitiveSearch].location != NSNotFound;
            searchCondition = searchCondition || [senderEmail rangeOfString:searchQuery options:NSCaseInsensitiveSearch].location != NSNotFound;
            searchCondition = searchCondition || [subject rangeOfString:searchQuery options:NSCaseInsensitiveSearch].location != NSNotFound;
            searchCondition = searchCondition || [fileName rangeOfString:searchQuery options:NSCaseInsensitiveSearch].location != NSNotFound;
            
            if (searchCondition) {
                [self.searchFilesArray addObject:[self.displayFilesArray objectAtIndex:i]];
                //                NSLog(@"Added Object %@", [self.inboxData objectAtIndex:i]);
            }
        }
        
        self.displayFilesArray = [[NSArray arrayWithArray:self.searchFilesArray] mutableCopy];
        
    }
    [self.attachmentsCollectionView reloadData];
}


#pragma mark - Text Field Delegate
-(void)textFieldDidBeginEditing:(nonnull UITextField *)textField {
    NSLog(@"TextFieldDidBeginEditing");
    self.isSearching = YES;
}

-(void)textFieldDidEndEditing:(nonnull UITextField *)textField {
    //Revert Inbox Data to Messages Data
    NSLog(@"TextFieldDidEndEditing");
    [textField resignFirstResponder];
    
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    //if we only try and resignFirstResponder on textField or searchBar,
    //the keyboard will not dissapear (at least not on iPad)!
    self.isSearching = NO;
    self.displayFilesArray = [self.attachmentsArray mutableCopy];
    [self.attachmentsCollectionView reloadData];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Save Attachments Array

-(void)saveData{
    [[NSUserDefaults standardUserDefaults] setObject:self.attachmentsArray forKey:@"attachmentsCache"];
}

-(void)loadData {
    self.attachmentsArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"attachmentsCache"] mutableCopy];
    if (self.attachmentsArray != NULL)
    {
        self.displayFilesArray = [self.attachmentsArray mutableCopy];
        [self.attachmentsCollectionView reloadData];
    }
}

-(void)clearData {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"attachmentsCache"];
}

#pragma mark - BaseViewControllerDelegate

-(void)topBarTouched {
    if ([self.attachmentsCollectionView numberOfSections] > 0)
    {
        NSIndexPath* top = [NSIndexPath indexPathForItem:0 inSection:0];
        [self.attachmentsCollectionView scrollToItemAtIndexPath:top atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
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
