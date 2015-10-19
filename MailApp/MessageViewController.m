//
//  MessageViewController.m
//  MailApp
//
//  Created by Shiv Sakhuja on 8/15/15.
//  Copyright © 2015 Shiv Sakhuja. All rights reserved.
//

#import "MessageViewController.h"
#import "ContextIOAPIInformation.h"
#import "NSDate+Utilities.h"
#import "YALContextMenuTableView.h"
#import "ContextMenuCell.h"
#import "AttachmentsViewController.h"

@interface MessageViewController () <UITableViewDelegate, UITableViewDataSource, YALContextMenuTableViewDelegate>

@property (nonatomic, strong) YALContextMenuTableView *contextMenuTableView;

@property (nonatomic, strong) NSArray *menuTitles;
@property (nonatomic, strong) NSArray *menuIcons;

@end

BOOL isHeaderViewShrunk;

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupTextView];
    [self setupView];
    
    [self hideData];
    [self loadData];
    
    isHeaderViewShrunk = NO;
    
    [self growHeaderView];
    [self setupNotifications];
    [self setupUnsubscribe];
    
    
    self.receivedArray = [[NSMutableArray alloc] init];
    self.messageWebView.scrollView.delegate = self;
    self.messageWebView.multipleTouchEnabled = YES;
    self.messageWebView.userInteractionEnabled = YES;
    
    //Navigation Bar
    [self setupNavigationBar];
    self.navigationController.navigationBar.translucent = NO;
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;   // iOS 7 specific
    
    [self setupHeaderView];
    [self hideDetails:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupNavigationBar];
}


-(void)setupNotifications {
    /**
     * Create the notification
     */
    self.minimalNotification = [JFMinimalNotification notificationWithStyle:JFMinimalNotificationStyleSuccess
                                                                      title:@"Unsubscribe Successful"
                                                                   subTitle:@"You have been unsubscribed from this list." dismissalDelay:1.5 touchHandler:^(void) {
                                                                       [self dismissNotification:self];
                                                                   }];
    
    
    
    /**
     * Set the desired font for the title and sub-title labels
     * Default is System Normal
     */
    UIFont* titleFont = [UIFont fontWithName:@"STHeitiK-Light" size:22];
    [self.minimalNotification setTitleFont:titleFont];
    UIFont* subTitleFont = [UIFont fontWithName:@"STHeitiK-Light" size:16];
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

-(BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)setupUnsubscribe {
    NSDictionary *listHeaders = self.messageData[@"list_headers"];
    if (listHeaders == NULL || [listHeaders objectForKey:@"list-unsubscribe"] == NULL) {
        NSLog(@"listHeaders equals NULL or list-unsubscribe equals NULL");
        unsubscribeButton.enabled = NO;
    }
    else {
        NSString *unsubscribeString = self.messageData[@"list_headers"][@"list-unsubscribe"];
        NSArray *unsubscribeArray = [unsubscribeString componentsSeparatedByString:@","];
        
        NSLog(@"Unsubscribe Array: %@", unsubscribeArray);
        if (unsubscribeArray.count != 0) {
            NSString *header = @"-99";
            for (NSString *item in unsubscribeArray) {
                if ([item rangeOfString:@"mailto" options:NSCaseInsensitiveSearch].location == NSNotFound) {
                    header = item;
                    break;
                }
                else {
                    
                }
            }
            if (![header isEqualToString:@"-99"]) {
                NSLog(@"header string is not equal to -99");
                unsubscribeButton.enabled = YES;
            }
            else {
                NSLog(@"header string is equal to -99");
                unsubscribeButton.enabled = NO;
            }
        }
    }
    

}

-(void)setupHeaderView {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.headerView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.1 green:0.1 blue:0.2 alpha:1] CGColor], (id)[[UIColor colorWithRed:0.1 green:0.2 blue:0.3 alpha:1] CGColor], nil];
    [self.headerView.layer insertSublayer:gradient atIndex:0];
    
    self.attachments.hidden = YES;
}

-(void)setupNavigationBar {
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.2 alpha:1.0]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                     [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0], NSFontAttributeName, nil]];
}

- (void)textViewDidChange:(UITextView *)textView{
    //    [self.threadTableView beginUpdates];
    height = textView.contentSize.height;
    //    [self.threadTableView endUpdates];
}

-(void)setupTextView {
    [self.messageTextView setText:@"Loading..."];
    [self.messageTextView setTextColor:[UIColor darkGrayColor]];
    [self.messageTextView setBackgroundColor:[UIColor clearColor]];
    [self.messageTextView setSpellCheckingType:UITextSpellCheckingTypeNo];
    [self.messageTextView setEditable:NO];
    [self.messageTextView setSelectable:YES];
    [self.messageTextView setFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0f]];
    [self.messageTextView setScrollEnabled:YES];
    //    [self.messageTextView setFrame:CGRectMake(self.messageTextView.frame.origin.x, self.messageTextView.frame.origin.y, self.messageTextView.frame.size.width, 800)];
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    //    NSLog(@"Scroll View did Scroll Called");
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    float actionDistance = 10;
    UIEdgeInsets inset = aScrollView.contentInset;
    //    NSLog(@"ScrollView offset.y: %f", offset.y);
    if(offset.y > actionDistance && !isHeaderViewShrunk) {
        //        NSLog(@"Hide top view");
        [self shrinkHeaderView];
        
    }
    else if (offset.y < 1) {
        [self growHeaderView];
    }
}


-(void)setupView {
    self.dateLabel.text = @"";
    self.senderLabel.text = @"";
    self.subjectLabel.text = @"";
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.messageDetailsView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.9 green:0.2 blue:0.3 alpha:1] CGColor], (id)[[UIColor colorWithRed:1 green:0.3 blue:0.6 alpha:1] CGColor], nil];
    [self.messageDetailsView.layer insertSublayer:gradient atIndex:0];
    
}


-(void)getMessage {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Getting Message with ID: %@", self.messageID);
        
        NSDictionary *params = @{@"include_body" : @(1),
                                 @"body_type" : @"text/html"
                                 };
        [[[ContextIOAPIInformation getAPIClient] getMessageWithID:self.messageID params:params] executeWithSuccess:^(NSDictionary *responseDict) {
            
            [self showData];
            
            self.messageData = [NSDictionary dictionaryWithDictionary:responseDict];
            
            [self displayData];
            [self saveData];
            
        } failure:^(NSError *error) {
            
            [self hideData];
            NSLog(@"Failed to get messages for selected contact. Error: %@", error.localizedDescription);
            
        }];
    });
}

-(void)displayData {
    [self showData];
    //Sender Email
    self.senderEmailID = self.messageData[@"addresses"][@"from"][@"email"];
    
    //Sender Label
    NSString *senderName = self.messageData[@"addresses"][@"from"][@"name"];
    if (senderName.length == 0) {
        senderName = self.senderEmailID;
    }
    self.senderLabel.text = senderName;
    detailSenderLabel.text = self.senderLabel.text;
    detailSenderEmail.text = self.senderEmailID;
    
    //Contact Image Label
    NSArray *senderNameArray = [senderName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (senderNameArray.count > 1) {
        detailContactImageLabel.text = [NSString stringWithFormat:@"%@%@", [senderNameArray[0] substringToIndex:1], [senderNameArray[1] substringToIndex:1]];
    }
    else {
        detailContactImageLabel.text = [senderName substringToIndex:1];
    }
    
    detailContactImageLabel.text = [detailContactImageLabel.text uppercaseString];
    
    // To Label
    self.receivedArray = [self.messageData[@"addresses"][@"to"] mutableCopy];
    NSLog(@"Received Array: %@", self.receivedArray);
    
    // Date Label
    NSNumber *unixDate = [self.messageData objectForKey:@"date"];
    NSString *dateString = [self dateLabelForUnixDate:[unixDate doubleValue]];
    self.dateLabel.text = dateString;
    detailDate.text = self.dateLabel.text;
    
    
    //Subject Label
    self.subjectLabel.text = [self.messageData objectForKey:@"subject"];
    
    //Attachments
    NSArray *filesArray = [self.messageData objectForKey:@"files"];
    if (filesArray == NULL || filesArray.count == 0) {
        detailAttachmentsImage.hidden = YES;
        detailAttachmentsButton.hidden = YES;
        self.attachments.hidden = YES;
    }
    else {
        detailAttachmentsImage.hidden = NO;
        detailAttachmentsButton.hidden = NO;
        [detailAttachmentsButton setTitle:[NSString stringWithFormat:@"%ld", filesArray.count] forState:UIControlStateNormal];
        self.attachments.hidden = NO;
    }
    
    //Message Body
    NSArray *messageBody = [self.messageData objectForKey:@"body"];
    if (messageBody.count == 0) {
        self.messageTextView.text = @"No Content.";
    }
    else {
        //                NSLog(@"Message Body: %@", messageBody);
        
        for (NSDictionary *bodyDict in messageBody) {
            if ([[bodyDict objectForKey:@"type"] isEqualToString:@"text/plain"]) {
                self.messageTextView.text = bodyDict[@"content"];
                self.messageTextView.hidden = NO;
                self.messageWebView.hidden = YES;
                NSLog(@"Plain text.");
            }
            if ([[bodyDict objectForKey:@"type"] isEqualToString:@"text/html"]) {
                self.messageWebView.hidden = NO;
                self.messageTextView.hidden = YES;
                NSString *htmlString = [messageBody firstObject][@"content"];
                NSString *finalHtmlString = [NSString stringWithFormat:@"<html><head></head><body style='background-color:transparent; font-family:Helvetica, sans-serif; font-size: 11pt;'>%@</body></html>", htmlString];
                [self.messageWebView loadHTMLString:finalHtmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
                NSLog(@"HTML Content.");
            }
            
        }
        
    }
    
    [self.receivedCollectionView reloadData];
}

-(void)showData {
    [detailAttachmentsButton setHidden:NO];
    [detailAttachmentsImage setHidden:NO];
    [detailContactImageLabel setHidden:NO];
    [detailDate setHidden:NO];
    [detailSenderEmail setHidden:NO];
    [detailSenderLabel setHidden:NO];
    [self.receivedCollectionView setHidden:NO];
    [self.messageDetailsBackgroundView setHidden:NO];
//    [self.messageDetailsView setHidden:NO];
    
}

-(void)hideData {
    [detailAttachmentsButton setHidden:YES];
    [detailAttachmentsImage setHidden:YES];
    [detailContactImageLabel setHidden:YES];
    [detailDate setHidden:YES];
    [detailSenderEmail setHidden:YES];
    [detailSenderLabel setHidden:YES];
    [self.receivedCollectionView setHidden:YES];
    [self.messageDetailsBackgroundView setHidden:YES];
    //    [self.messageDetailsView setHidden:YES];
}

-(IBAction)showForwardVC:(id)sender {
    
    if ([MFMailComposeViewController canSendMail])
    {
        
        NSArray *messageBody = [self.messageData objectForKey:@"body"];
        if (messageBody.count == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Cannot forward this email!" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        NSString *htmlString = [messageBody firstObject][@"content"];
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:[NSString stringWithFormat:@"Fwd: %@", self.subjectLabel.text]];
        [mail setMessageBody:htmlString isHTML:YES];
        [mail setToRecipients:nil];
        
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
        NSLog(@"This device cannot send email");
    }
}

-(IBAction)showReplyVC:(id)sender {
    
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:[NSString stringWithFormat:@"Re: %@", self.subjectLabel.text]];
        [mail setMessageBody:@"" isHTML:NO];
        [mail setToRecipients:@[self.senderEmailID]];
        
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
        NSLog(@"This device cannot send email");
    }
}

-(IBAction)showReplyAllVC:(id)sender {
    
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:[NSString stringWithFormat:@"Fwd: %@", self.subjectLabel.text]];
        [mail setMessageBody:@"" isHTML:NO];
        NSMutableArray *recipientsArray = [NSMutableArray arrayWithArray:self.receivedArray];
        [recipientsArray addObject:self.senderEmailID];
        
        [mail setToRecipients:recipientsArray];
        
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
        NSLog(@"This device cannot send email");
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    if(error) NSLog(@"ERROR - mailComposeController: %@", [error localizedDescription]);
    [self dismissModalViewControllerAnimated:YES];
    return;
}



-(NSString *)dateLabelForUnixDate:(double)unixDate {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:unixDate];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mma, MM/dd/YYYY"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    if ([date isToday])
    {
        dateString = @"Today at ";
        [dateFormatter setDateFormat:@"h:mma"];
        dateString = [dateString stringByAppendingString:[dateFormatter stringFromDate:date]];
    }
    else if ([date isYesterday]) {
        dateString = @"Yesterday at ";
        [dateFormatter setDateFormat:@"h:mma"];
        dateString = [dateString stringByAppendingString:[dateFormatter stringFromDate:date]];
    }
    else {
        // Do Nothing
        dateString = [dateFormatter stringFromDate:date];
    }
    
    return dateString;
}




-(void)shrinkHeaderView {
    
    //    NSLog(@"ShrinkHeaderView Called");
    CGRect frame_headerView = self.headerView.frame;
    frame_headerView = CGRectMake(0, -200, self.headerView.frame.size.width, self.headerView.frame.size.height);
    
    CGRect frame_messageTextView = self.messageTextView.frame;
    frame_messageTextView = CGRectMake(self.messageTextView.frame.origin.x, 0, self.messageTextView.frame.size.width, self.view.frame.size.height);
    
    CGRect frame_messageWebView = self.messageWebView.frame;
    frame_messageWebView = frame_messageTextView;
    
    [UIView setAnimationDuration:0.3];
    [UIView beginAnimations:nil context:nil];
    
    self.headerView.frame = frame_headerView;
    self.headerView.layer.masksToBounds = YES;
    
    self.messageTextView.frame = frame_messageTextView;
    self.messageWebView.frame = frame_messageWebView;
    
    [self.navigationController setNavigationBarHidden:YES];
    
    [UIView commitAnimations];
    
    isHeaderViewShrunk = YES;
}

-(void)growHeaderView {
    
    //    NSLog(@"growHeaderView Called");
    CGRect frame_headerView = self.headerView.frame;
    frame_headerView = CGRectMake(0, 0, self.headerView.frame.size.width, self.headerView.frame.size.height);
    
    CGRect frame_messageTextView = self.messageTextView.frame;
    frame_messageTextView = CGRectMake(self.messageTextView.frame.origin.x, frame_headerView.size.height+20, self.messageTextView.frame.size.width, self.view.frame.size.height - frame_headerView.size.height - 20);
    
    CGRect frame_messageWebView = self.messageWebView.frame;
    frame_messageWebView = frame_messageTextView;
    
    
    [UIView setAnimationDuration:0.3];
    [UIView beginAnimations:nil context:nil];
    
    self.headerView.frame = frame_headerView;
    self.headerView.layer.masksToBounds = YES;
    
    self.messageTextView.frame = frame_messageTextView;
    self.messageWebView.frame = frame_messageWebView;
    
    [self.navigationController setNavigationBarHidden:NO];
    
    [UIView commitAnimations];
    
    isHeaderViewShrunk = NO;
}


#pragma mark - Collection View Methods



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.receivedArray count];
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    UILabel *receivedLabel = (UILabel *)[cell viewWithTag:99];
    if (self.receivedArray != NULL) {
        [receivedLabel setText:[self.receivedArray[indexPath.row] objectForKey:@"name"]];
        if (receivedLabel.text.length == 0) {
            receivedLabel.text = self.receivedArray[indexPath.row][@"email"];
        }
    }
    
    UILabel *emailLabel = (UILabel *)[cell viewWithTag:98];
    emailLabel.text = self.receivedArray[indexPath.row][@"email"];
    
    return cell;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //Get Contact Info
    
}

-(NSInteger)numberOfSectionsInCollectionView:(nonnull UICollectionView *)collectionView {
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *receivedString = (NSString*)[[self.receivedArray objectAtIndex:indexPath.row] objectForKey:@"name"];
    if (receivedString.length == 0) {
        receivedString = (NSString*)[[self.receivedArray objectAtIndex:indexPath.row] objectForKey:@"email"];
    }
    
    
    return [receivedString sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:18]}];
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView
{
    //    CGSize contentSize = theWebView.scrollView.contentSize;
    //    CGSize viewSize = self.view.bounds.size;
    //
    //    float rw = viewSize.width / contentSize.width;
    //
    //    theWebView.scrollView.minimumZoomScale = rw;
    //    theWebView.scrollView.maximumZoomScale = rw;
    //    theWebView.scrollView.zoomScale = rw;
    NSLog(@"WebView Size Corrected");
    theWebView.scrollView.zoomScale = 1.0 / theWebView.scrollView.minimumZoomScale;
}



#pragma mark - IBAction

- (IBAction)presentMenuButtonTapped:(UIBarButtonItem *)sender {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Choose Action"
                                          message:@"Select the action you would like to perform on this message"
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *replyAction = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"Reply", @"OK action")
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      NSLog(@"Reply action");
                                      [self showReplyVC:self];
                                  }];
    
    UIAlertAction *replyAllAction = [UIAlertAction
                                     actionWithTitle:NSLocalizedString(@"Reply to All", @"OK action")
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                     {
                                         NSLog(@"Reply All action");
                                         [self showReplyAllVC:self];
                                     }];
    
    UIAlertAction *forwardAction = [UIAlertAction
                                    actionWithTitle:NSLocalizedString(@"Forward", @"OK action")
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action)
                                    {
                                        NSLog(@"Forward action");
                                        [self showForwardVC:self];
                                    }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"OK action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];
    
    [alertController addAction:replyAction];
    [alertController addAction:replyAllAction];
    [alertController addAction:forwardAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(IBAction)showDetails:(id)sender {
    NSLog(@"showDetails running");
    //    self.messageDetailsBackgroundView.hidden = NO;
    //    CGRect detailsFrame = self.messageDetailsView.frame;
    //    detailsFrame.origin.x = (self.view.frame.size.width - self.messageDetailsView.frame.size.width)/2;
    
    [UIView setAnimationDuration:0.2];
    [UIView beginAnimations:nil context:nil];
    
    self.messageDetailsBackgroundView.alpha = 1.0;
    //    self.messageDetailsView.frame = detailsFrame;
    
    [UIView commitAnimations];
}

-(IBAction)hideDetails:(id)sender {
    NSLog(@"hideDetails running");
    //    self.messageDetailsBackgroundView.hidden = YES;
    //    CGRect detailsFrame = self.messageDetailsView.frame;
    //    detailsFrame.origin.x = self.view.frame.size.width;
    //    detailsFrame.origin.y = (self.view.frame.size.height - self.messageDetailsView.frame.size.height)/2;
    
    [UIView setAnimationDuration:0.2];
    [UIView beginAnimations:nil context:nil];
    
    self.messageDetailsBackgroundView.alpha = 0.0;
    
    //    self.messageDetailsView.frame = detailsFrame;
    
    [UIView commitAnimations];
    
}


-(IBAction)showAttachments:(id)sender {
    AttachmentsViewController *attachmentsVC = (AttachmentsViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"attachmentsVC"];
    attachmentsVC.attachmentsArray = [NSArray arrayWithArray:self.messageData[@"files"]];
    attachmentsVC.senderEmail = @"-95";
    attachmentsVC.navController = self.navigationController;
    [self.navigationController pushViewController:attachmentsVC animated:YES];
}


#pragma mark - Unsubscribe

-(IBAction)unsubscribeButtonPressed:(id)sender {
    NSString *unsubscribeString = self.messageData[@"list_headers"][@"list-unsubscribe"];
    NSArray *unsubscribeArray = [unsubscribeString componentsSeparatedByString:@","];
    
    NSLog(@"Unsubscribe Array: %@", unsubscribeArray);
    if (unsubscribeArray.count != 0) {
        NSString *header;
        for (NSString *item in unsubscribeArray) {
            if ([item rangeOfString:@"mailto" options:NSCaseInsensitiveSearch].location == NSNotFound) {
                header = item;
                break;
            }
        }
        if (header != NULL) {
            [self unsubscribeToMailWithHeader:header];
        }
    }
    else {
        //Error
        NSLog(@"Could not unsubscribe");
    }
}


-(void)unsubscribeToMailWithHeader:(NSString *)unsubscribeHeader {
    
    unsubscribeHeader = [unsubscribeHeader stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([[unsubscribeHeader substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"<"]) {
        unsubscribeHeader = [unsubscribeHeader substringWithRange:NSMakeRange(1, unsubscribeHeader.length - 2)];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:unsubscribeHeader]];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // Success handling here
    NSLog(@"Unsubscribe Successful with response: %@", response);
    [self.minimalNotification show];
}



- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // Error handling here
    NSLog(@"Unsubscribe Failed With Error %@", error.localizedDescription);
    self.minimalNotification = [JFMinimalNotification notificationWithStyle:JFMinimalNotificationStyleError title:@"Error!" subTitle:@"You could not be unsubscribed from this list" dismissalDelay:1.5 touchHandler:^(void) {
        [self dismissNotification:self];
    }];
    [self.minimalNotification show];
}

- (IBAction)dismissNotification:(id)sender {
    [self.minimalNotification dismiss];
}

- (IBAction)archiveMessage:(id)sender {
    //Archive Message
    [self hideDetails:nil];
    NSDictionary *params = @{@"add":@"MailApp/Archived",
                             @"remove":@"INBOX"};
    [[[ContextIOAPIInformation getAPIClient] updateFoldersForMessageWithID:[NSString stringWithFormat:@"%@", self.messageID] params:params] executeWithSuccess:^(NSDictionary *responseDict) {
        NSLog(@"Message with ID %@ archived.", self.messageID);
        self.minimalNotification = [JFMinimalNotification notificationWithStyle:JFMinimalNotificationStyleSuccess title:@"Success!" subTitle:@"The message has been archived." dismissalDelay:1.0 touchHandler:^(void) {
            [self dismissNotification:self];
        }];
        [self.view addSubview:self.minimalNotification];
        [self.minimalNotification show];
    }
                                                                                                                                                       failure:^(NSError *error) {
                                                                                                                                                           NSLog(@"Message with ID %@ could not be archived. Error %@", self.messageID, error);
                                                                                                                                                       }];
    
}


#pragma mark - Save / Load / Clear Message Data

-(void)saveData{
    [[NSUserDefaults standardUserDefaults] setObject:self.messageData forKey:self.messageID];
}

-(void)loadData {
    self.messageData = [[[NSUserDefaults standardUserDefaults] objectForKey:self.messageID] mutableCopy];
    if (self.messageData != NULL)
    {
        [self displayData];
    }
    else {
        [self getMessage];
    }
}

-(void)clearData {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:self.messageID];
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
