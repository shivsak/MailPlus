//
//  ImageViewController.m
//  MailApp
//
//  Created by Shiv Sakhuja on 8/29/15.
//  Copyright © 2015 Shiv Sakhuja. All rights reserved.
//

#import "ImageViewController.h"
#import "MessageViewController.h"
#import "ContextIOAPIInformation.h"

@interface ImageViewController ()

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupNavigationBar];
    [self setupNotifications];
    [self.imageView setImage:self.image];
    [self.imageNameLabel setText:self.imageName];
    if (self.image == nil && self.fileID != NULL) {
        [self setupActivityIndicator];
        [self getImageForFileWithID:self.fileID];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupNavigationBar];
}


-(BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupActivityIndicator {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.activityIndicator setFrame:CGRectMake((self.view.frame.size.width - 50)/2, (self.view.frame.size.height - 50)/2, 50, 50)];
    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
}

-(void)setupNavigationBar {
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBarTintColor:[UIColor blackColor]];
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
    [self setTitle:@""];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor whiteColor],
                                                                     NSForegroundColorAttributeName,
                                                                     [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0], NSFontAttributeName, nil]];
}

-(IBAction)viewMessage:(id)sender {
    MessageViewController *messageVC = (MessageViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"messageVC"];
    messageVC.messageID = self.messageID;
    [self.navigationController pushViewController:messageVC animated:YES];
}

-(IBAction)showShareSheet:(id)sender {
    if (self.image != nil) {
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[self.image] applicationActivities:nil];
        NSArray *excludeActivities = @[UIActivityTypeAddToReadingList,
                                       UIActivityTypePostToWeibo,
                                       UIActivityTypePostToTencentWeibo
                                       ];
        
        activityController.excludedActivityTypes = excludeActivities;
        [self presentViewController:activityController animated:YES completion:nil];
    }
}

-(void)getImageForFileWithID:(NSString *)fileID {
    NSLog(@"getting Images for File ID: %@", fileID);
    
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *fileURL = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@", fileID]];
    if ([fileURL checkResourceIsReachableAndReturnError:nil]) {
        [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
    }
    [[ContextIOAPIInformation getAPIClient] downloadRequest:[[ContextIOAPIInformation getAPIClient] downloadContentsOfFileWithID:fileID]
                                                  toFileURL:fileURL
                                                    success:^{
                                                        
                                                        NSLog(@"File downloaded to %@:", [fileURL path]);
                                                        UIImage *image = [UIImage imageWithContentsOfFile:[fileURL path]];
                                                        NSLog(@"Image: %@", image);
                                                        self.imageView.image = image;
                                                        self.image = image;
                                                        [self.activityIndicator stopAnimating];
                                                        
                                                    }
                                                    failure:^(NSError *error) {
                                                        NSLog(@"Download error: %@", error);
                                                        [self.minimalNotification show];
                                                        [self.activityIndicator stopAnimating];
                                                    }
                                                   progress:^(int64_t bytesRead, int64_t totalBytesRead, int64_t totalBytesExpected){
                                                       //                               NSLog(@"Download progress: %0.2f%%", ((double)totalBytesExpected / (double)totalBytesRead) * 100);
                                                   }];
}



-(void)setupNotifications {
    /**
     * Create the notification
     */
    self.minimalNotification = [JFMinimalNotification notificationWithStyle:JFMinimalNotificationStyleWarning
                                                                      title:@"Error"
                                                                   subTitle:@"Could not download the image. Tap to dismiss." dismissalDelay:0.0 touchHandler:^(void) {
                                                                       [self dismissNotification:self];
                                                                   }];
    
    
    
    /**
     * Set the desired font for the title and sub-title labels
     * Default is System Normal
     */
    UIFont *titleFont = [UIFont fontWithName:@"HelveticaNeue" size:19.0f];
    [self.minimalNotification setTitleFont:titleFont];
    UIFont *subTitleFont = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
    [self.minimalNotification setSubTitleFont:subTitleFont];
    
    /**
     * Set any necessary edge padding as needed
     */
    self.minimalNotification.edgePadding = UIEdgeInsetsMake(0, 0, 10, 0);
    
    /**
     * Add the notification to a view
     */
    [self.view addSubview:self.minimalNotification];
}

-(IBAction)dismissNotification:(id)sender {
    [self.minimalNotification dismiss];
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
