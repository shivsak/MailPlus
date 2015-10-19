//
//  ThreadViewController.m
//  MailApp
//
//  Created by Shiv Sakhuja on 8/13/15.
//  Copyright © 2015 Shiv Sakhuja. All rights reserved.
//

#import "ThreadViewController.h"
#import "ThreadTableViewCell.h"
#import "MessageViewController.h"
#import "AttachmentsViewController.h"
#import "PhotosViewController.h"
#import "ComposeViewController.h"
#import "ContextIOAPIInformation.h"
#import "NSDate+Utilities.h"

@interface ThreadViewController ()

@end

BOOL isBaseHeaderViewShrunk;

int DEFAULT_ROW_HEIGHT = 100;
int HEADER_HEIGHT = 116;

@implementation ThreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    height = DEFAULT_ROW_HEIGHT;
    
    self.messagesData = [[NSMutableArray alloc] init];
    self.threadData = [[NSMutableArray alloc] init];
    
    [self getMessagesWithOffset:0];
    [self setupTableView];
    [self setupView];
    
    [self.navigationController setNavigationBarHidden:NO];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupNavigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupNavigationBar {
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:1 green:0.2 blue:0.3 alpha:1.0]];
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor whiteColor],
                                                                     NSForegroundColorAttributeName,
                                                                     [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0], NSFontAttributeName, nil]];
}

-(BOOL)prefersStatusBarHidden {
    return NO;
}

-(void)setupView {
    //    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1]];
    //    [self.navigationController.navigationBar setTintColor:[UIColor darkGrayColor]];
    //    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
    //                                                                                [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0], NSForegroundColorAttributeName,
    //                                                                                [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0], NSFontAttributeName, nil]];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:1] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    [self.threadTableView setSeparatorColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1]];
    [self.view setBackgroundColor:[UIColor blackColor]];
}


#pragma mark - Data


-(void)getMessagesWithOffset:(int)offset {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Getting Messages for Contact: %@", self.senderEmail);
        int limit = 100;
        
        if (offset == 0) {
            [self.messagesData removeAllObjects];
        }
        
        NSDictionary *params = @{
                                 @"limit": @(limit),
                                 @"offset": @(offset),
                                 @"include_body" : @(1),
                                 @"include_flags" : @(1)
                                };
        [[[ContextIOAPIInformation getAPIClient] getMessagesForContactWithEmail:self.senderEmail params:params] executeWithSuccess:^(NSArray *responseDict) {
            //Success
            NSLog(@"Got messages for selected contact. Count: %ld", [responseDict count]);
            int messageCount = (int)[responseDict count];
            if (messageCount == limit) {
//                self.baseUserMessagesCount.text = [[NSString stringWithFormat:@"%ld+ \nmessages", [responseDict count]] uppercaseString];
                [[[ContextIOAPIInformation getAPIClient] getContactWithEmail:self.senderEmail params:nil] executeWithSuccess:^(NSDictionary *dict) {
                    self.baseUserMessagesCount.text = [[NSString stringWithFormat:@"%@ \nmessages", dict[@"count"]] uppercaseString];
                } failure:^(NSError *error) {
                    NSLog(@"Could not retrieve contact info.");
                }];
            }
            else {
                self.baseUserMessagesCount.text = [[NSString stringWithFormat:@"%ld \nmessages", [responseDict count]] uppercaseString];
            }
            
            NSLog(@"ResponseDict: %@", responseDict);
            if (offset == 0) {
                self.messagesData = [responseDict mutableCopy];
            }
            else {
                [self.messagesData addObjectsFromArray:responseDict];
            }
            
            
            self.threadData = [self.messagesData mutableCopy];
            [self.threadTableView reloadData];
            
        } failure:^(NSError *error) {
            NSLog(@"Failed to get messages for selected contact. Error: %@", error.localizedDescription);
        }];
    });
}

#pragma mark - Table View

-(void)setupTableView {
    //Setup Table View
}

-(NSInteger)numberOfSectionsInTableView:(nonnull UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.threadData.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return DEFAULT_ROW_HEIGHT;
}



- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.0;
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0;
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}


-(UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ThreadTableViewCell *cell;
    
    [cell.leftSidebarView setHidden:YES];
    
    static NSString *CellIdentifier = @"Cell";
    
    if (cell == nil) {
        cell = [[ThreadTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //Attachments
    if ([self.threadData[indexPath.row] objectForKey:@"files"] == NULL) {
        cell.attachment.hidden = YES;
    }
    else {
        cell.attachment.hidden = NO;
        cell.attachment.alpha = 0.6;
    }
    
    
    //Read / Seen Label
    NSArray *flags = self.threadData[indexPath.row][@"flags"];
    if ([self isMessageSeen:flags]) {
        //Message is read
        NSLog(@"Message is Read");
        cell.readLabel.hidden = YES;
    }
    else {
        //Message is unread
        NSLog(@"Message is unread");
        cell.readLabel.hidden = NO;
        cell.readLabel.alpha = 0.6;
    }
    
    
    cell.messageID = self.threadData[indexPath.row][@"message_id"];
    cell.subjectLabel.text = self.threadData[indexPath.row][@"subject"];
    
    NSArray *messageBody = self.threadData[indexPath.row][@"body"];
    if (messageBody.count != 0) {
        cell.messageLabel.text = [messageBody firstObject][@"content"];
    }
    else {
        cell.messageLabel.text = @"No Content";
    }
    
    
    
    NSNumber *unixDate = self.threadData[indexPath.row][@"date"];
    NSString *dateString = [self dateLabelForUnixDate:[unixDate doubleValue]];
    cell.dateTimeLabel.text = dateString;
    
    //Resize TextView
    //    [cell.messageTextView setDelegate:self];
    //    [cell.messageTextView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight]; // It will automatically resize TextView as cell resizes.
    //    cell.messageTextView.backgroundColor = [UIColor clearColor]; // Just because it is my favourite
    //    [self textViewDidChange:cell.messageTextView];
    
    
    // Selection Color
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor colorWithRed:0.8 green:0.2 blue:0.3 alpha:1];
    cell.selectedBackgroundView = selectionColor;
    
    return cell;
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // you need to implement this method too or nothing will work:
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Present MessageViewController{
    //        [self performSegueWithIdentifier:@"showMessage" sender:self];
    ThreadTableViewCell *cell = (ThreadTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
    MessageViewController *messageVC = (MessageViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"messageVC"];
    messageVC.messageID = cell.messageID;
    [self.navController pushViewController:messageVC animated:YES];
    
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *replyButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Reply" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                         {
                                             //Action for Button Here
                                             //                                               [self request:indexPath];
                                         }];
    [replyButton setBackgroundColor:[UIColor colorWithRed:0.2 green:0.7 blue:0.9 alpha:1.0]];
    
    UITableViewRowAction *forwardButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Forward" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                           {
                                               //Action for Button Here
                                               //                                             [self share:indexPath];
                                           }];
    [forwardButton setBackgroundColor:[UIColor colorWithRed:0.9 green:0.7 blue:0.1 alpha:1.0]];
    
    UITableViewRowAction *deleteButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                          {
                                              //Action for Button Here
                                              //                                             [self share:indexPath];
                                          }];
    [deleteButton setBackgroundColor:[UIColor colorWithRed:0.9 green:0.1 blue:0.1 alpha:1.0]];
    
    return @[deleteButton, forwardButton, replyButton];
}


#pragma mark Tab Actions

-(IBAction)tabButtonPressed:(id)sender {
    if (self == self.navigationController.topViewController) {
        if ([sender tag] ==0) {
            // messages - do nothing
        }
        else if ([sender tag] == 1) {
            // attachments
            [self performSegueWithIdentifier:@"showAttachmentsThread" sender:self];
            AttachmentsViewController *attachmentsVC = (AttachmentsViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"attachmentsVC"];
            attachmentsVC.senderEmail = self.senderEmail;
        }
        else {
            // photos
            [self performSegueWithIdentifier:@"showPhotosThread" sender:self];
            PhotosViewController *photosVC = (PhotosViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"photosVC"];
            photosVC.senderEmail = self.senderEmail;
        }
        
    }
}

-(IBAction)showComposeVC:(id)sender {
    [self performSegueWithIdentifier:@"showComposeTo" sender:self];
    ComposeViewController *composeVC = (ComposeViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"composeVC"];
    //    composeVC.toUser = self.threadID;
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    NSLog(@"Scroll View did Scroll Called");
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    float actionDistance = 10;
    UIEdgeInsets inset = aScrollView.contentInset;
    NSLog(@"ScrollView offset.y: %f", offset.y);
    if(offset.y > actionDistance && !isBaseHeaderViewShrunk) {
        NSLog(@"Hide top view");
        [self shrinkHeaderView];
        
    }
    else if (offset.y < 1) {
        [self growHeaderView];
    }
}

-(void)shrinkHeaderView {
    
    NSLog(@"ShrinkHeaderView Called");
    CGRect frame_headerView = self.baseHeaderView.frame;
    frame_headerView = CGRectMake(0, -140, self.baseHeaderView.frame.size.width, self.baseHeaderView.frame.size.height);
    
    CGRect frame_pageMenu = self.baseView.frame;
    frame_pageMenu = CGRectMake(self.baseView.frame.origin.x, frame_headerView.origin.y + frame_headerView.size.height, self.baseView.frame.size.width, self.baseView.frame.size.height);
    
    CGRect frame_tableView = self.threadTableView.frame;
    //    frame_tableView = CGRectMake(frame_pageMenu.origin.x, frame_pageMenu.origin.y, frame_pageMenu.size.width, self.view.frame.size.height - 40);
    frame_tableView = CGRectMake(0, 0, frame_pageMenu.size.width, frame_pageMenu.size.height);
    
    [UIView setAnimationDuration:0.2];
    [UIView beginAnimations:nil context:nil];
    
    self.baseHeaderView.frame = frame_headerView;
    //    self.baseHeaderView.layer.masksToBounds = YES;
    
    self.baseView.frame = frame_pageMenu;
    
    [UIView commitAnimations];
    
    isBaseHeaderViewShrunk = YES;
}

-(void)growHeaderView {
    
    NSLog(@"growHeaderView Called");
    CGRect frame_headerView = self.baseHeaderView.frame;
    frame_headerView = CGRectMake(0, 0, self.baseHeaderView.frame.size.width, self.baseHeaderView.frame.size.height);
    
    CGRect frame_pageMenu = self.baseView.frame;
    frame_pageMenu = CGRectMake(0, frame_headerView.size.height, self.baseView.frame.size.width, self.baseView.frame.size.height);
    
    
    CGRect frame_tableView = self.threadTableView.frame;
    frame_tableView = CGRectMake(0, 0, frame_pageMenu.size.width, self.view.frame.size.height - self.baseView.frame.origin.y);
    
    [UIView setAnimationDuration:0.2];
    [UIView beginAnimations:nil context:nil];
    
    self.baseHeaderView.frame = frame_headerView;
    self.baseHeaderView.layer.masksToBounds = YES;
    
    self.baseView.frame = frame_pageMenu;
    
    self.threadTableView.frame = frame_tableView;
    
    [UIView commitAnimations];
    
    isBaseHeaderViewShrunk = NO;
}


-(NSString *)dateLabelForUnixDate:(double)unixDate {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:unixDate];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    if ([date isToday])
    {
        [dateFormatter setDateFormat:@"h:mma"];
        dateString = [dateFormatter stringFromDate:date];
    }
    else if ([date isYesterday]) {
        dateString = @"Yesterday";
    }
    else {
        // Do Nothing
    }
    
    return dateString;
}

-(NSString *)labelTextForMessageWithFolders:(NSArray *)folders {
    
    for (NSString* item in folders)
    {
        if ([item rangeOfString:@"Draft"].location != NSNotFound) {
            return @"Draft";
        }
        else if ([item rangeOfString:@"Sent"].location != NSNotFound) {
            return @"Sent";
        }
        else if ([item rangeOfString:@"Important"].location != NSNotFound) {
            return @"Imp";
        }
    }
    
    return @"Not Imp";
}

-(BOOL)isMessageSeen:(NSArray *)flags {
    
    NSLog(@"Flags: %@", flags);
    for (NSString* item in flags)
    {
        NSLog(@"Flag Item: %@", item);
        if ([item rangeOfString:@"Seen" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            return YES;
        }
    }
    
    return NO;
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
