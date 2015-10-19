//
//  ViewController.m
//  MailApp
//
//  Created by Shiv Sakhuja on 8/13/15.
//  Copyright © 2015 Shiv Sakhuja. All rights reserved.
//

#import "ViewController.h"
#import "InboxTableViewCell.h"
#import "ThreadViewController.h"
#import "AttachmentsViewController.h"
#import "PhotosViewController.h"
#import <SSKeychain/SSKeychain.h>
#import "MessageViewController.h"
#import "ContextIOAPIInformation.h"
#import "CustomAlertView.h"
#import "NSDate+Utilities.h"
#import "SVPullToRefresh.h"

@interface ViewController ()
@property BOOL isLoadingMoreData;
@property BOOL isSearching;
@property long loadedMessages;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Load Data
    [self loadData];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self setupGradient];
    
    if (self.inboxData == NULL) {
        self.inboxData = [[NSMutableArray alloc] init];
    }
    
    self.searchData = [[NSMutableArray alloc] init];
    [self setupTableView];
    self.isSearching = NO;
    self.loadedMessages = 0;
    NSLog(@"getMessages");
    [self getMessagesWithOffset:0];
    
}

-(void)setupGradient {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //    [self setupNavigationBar];
    
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)applyFilter {
    
    NSLog(@"Apply Filter %@", self.filter);
    
    if ([self.filter isEqualToString:@"All"]) {
        NSLog(@"All Mails");
        //Do Nothing
        self.inboxData = [self.messagesData mutableCopy];
        
    }
    else if ([self.filter isEqualToString:@"Imp"]) {
        NSLog(@"Imp Mails only");
        [self.inboxData removeAllObjects];
        
        NSLog(@"MessagesData Count %ld", self.messagesData.count);
        
        for (NSDictionary *dict in self.messagesData) {
            NSArray *folders = [dict objectForKey:@"folders"];
            for (NSString* item in folders)
            {
                if ([item rangeOfString:@"Important" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                    [self.inboxData addObject:dict];
                    break;
                }
            }
        }
        
    }
    
    else if ([self.filter isEqualToString:@"Sent"]) {
        NSLog(@"Sent Mails only");
        [self.inboxData removeAllObjects];
        
        for (int i=0; i<[self.messagesData count]; i++) {
            NSArray *folders = [[self.messagesData objectAtIndex:i] objectForKey:@"folders"];
            
            for (NSString* item in folders)
            {
                if ([item rangeOfString:@"Sent" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                    [self.inboxData addObject:[self.messagesData objectAtIndex:i]];
                    break;
                }
            }
        }
        
    }
    
    else if ([self.filter isEqualToString:@"Drafts"]) {
        NSLog(@"Drafts only");
        [self.inboxData removeAllObjects];
        
        for (int i=0; i<[self.messagesData count]; i++) {
            NSArray *folders = [[self.messagesData objectAtIndex:i] objectForKey:@"folders"];
            
            for (NSString* item in folders)
            {
                if ([item rangeOfString:@"Draft" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                    [self.inboxData addObject:[self.messagesData objectAtIndex:i]];
                    break;
                }
            }
        }
    }
    
    else if ([self.filter isEqualToString:@"Unread"]) {
        NSLog(@"Unread only");
        [self.inboxData removeAllObjects];
        
        for (int i=0; i<[self.messagesData count]; i++) {
            NSArray *flags = [[self.messagesData objectAtIndex:i] objectForKey:@"flags"];
            
            BOOL *isUnread = TRUE;
            for (NSString* item in flags)
            {
                if ([item rangeOfString:@"Seen" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                    isUnread = FALSE;
                }
            }
            if (isUnread) {
                [self.inboxData addObject:[self.messagesData objectAtIndex:i]];
            }
        }
    }
    
    //    NSLog(@"Self.InboxData %@", self.inboxData);
    [self.inboxTableView reloadData];
    if ([self.inboxTableView numberOfRowsInSection:1] < 10 && !self.isSearching && !self.isLoadingMoreData) {
//        [self getMessagesWithOffset:self.loadedMessages];
    }
    
}



#pragma mark - Table View

-(void)setupTableView {
    [self.inboxTableView addPullToRefreshWithActionHandler:^{
        [self getMessagesWithOffset:0];
    }];
    [self.inboxTableView.pullToRefreshView setArrowColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.8]];
    [self.inboxTableView.pullToRefreshView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [self.inboxTableView.pullToRefreshView setTextColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.8]];
    [self.inboxTableView setSeparatorColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1]];
}

-(NSInteger)numberOfSectionsInTableView:(nonnull UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        // Search
        return 45;
    }
    else {
        // Threads
        return 78;
    }
}


-(NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    else {
        if (self.isSearching) {
            return [self.searchData count];
        }
        else {
            return [self.inboxData count];
        }
    }
}

-(UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    InboxTableViewCell *cell;
    
    if (indexPath.section == 0) {
        if (cell == nil) {
            cell = [[InboxTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Search"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"Search"];
        }
        
        return cell;
    }
    
    else {
        
        static NSString *CellIdentifier = @"Cell";
        
        if (cell == nil) {
            cell = [[InboxTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        NSString *senderName = @"";
        NSArray *folders = [[NSArray alloc] init];
        
        if (!self.isSearching) {
            //If Not Searching
            if (self.inboxData.count > indexPath.row) {
                
                //Attachments
                if ([self.inboxData[indexPath.row] objectForKey:@"files"] == NULL) {
                    cell.attachment.hidden = YES;
                }
                else {
                    cell.attachment.hidden = NO;
                    cell.attachment.alpha = 0.6;
                }
                
                cell.readLabel.hidden = YES;
                // Read / Seen Label
                NSArray *flags = self.inboxData[indexPath.row][@"flags"];
                if ([self isMessageSeen:flags]) {
                    //Message is read
                    cell.readLabel.hidden = YES;
                }
                else {
                    //Message is unread
                    cell.readLabel.hidden = NO;
                    cell.readLabel.alpha = 0.6;
                }
                
                
                //Folders
                folders = [[self.inboxData objectAtIndex:indexPath.row] objectForKey:@"folders"];
                
                cell.importantLabel.text = [self labelTextForMessageWithFolders:folders];
                if ([cell.importantLabel.text isEqualToString:@"Draft"]) {
                    cell.importantLabel.backgroundColor = [UIColor colorWithRed:0.6 green:0.3 blue:0.6 alpha:1];
                }
                
                else if ([cell.importantLabel.text isEqualToString:@"Sent"]) {
                    cell.importantLabel.backgroundColor = [UIColor colorWithRed:0.3 green:0.8 blue:0.6 alpha:1];
                }
                
                else if ([cell.importantLabel.text isEqualToString:@"Imp"]) {
                    cell.importantLabel.backgroundColor = [UIColor colorWithRed:1 green:0.2 blue:0.3 alpha:1];
                }
                
                else {
                    //Not Imp
                    cell.importantLabel.backgroundColor = [UIColor colorWithRed:0.1 green:0.2 blue:0.3 alpha:1.0f];
                }
                
                cell.senderEmail = [[[[self.inboxData objectAtIndex:indexPath.row] objectForKey:@"addresses"] objectForKey:@"from"] objectForKey:@"email"];
                
                //If Email is Sent
                if ([cell.importantLabel.text isEqualToString:@"Sent"] || [cell.importantLabel.text isEqualToString:@"Draft"]) {
                    senderName = [[[[[self.inboxData objectAtIndex:indexPath.row] objectForKey:@"addresses"] objectForKey:@"to"] objectAtIndex:0] objectForKey:@"name"];
                    if ([senderName isEqual:NULL]) {
                        senderName = [[[[[self.inboxData objectAtIndex:indexPath.row] objectForKey:@"addresses"] objectForKey:@"to"] objectAtIndex:0] objectForKey:@"email"];
                    }
                    cell.senderEmail = [[[[[self.inboxData objectAtIndex:indexPath.row] objectForKey:@"addresses"] objectForKey:@"to"] firstObject] objectForKey:@"email"];
                }
                else {
                    senderName = [[[[self.inboxData objectAtIndex:indexPath.row] objectForKey:@"addresses"] objectForKey:@"from"] objectForKey:@"name"];
                }
                
                cell.senderName = senderName;
                cell.senderLabel.text = senderName;
                cell.subjectLabel.text = [[self.inboxData objectAtIndex:indexPath.row] objectForKey:@"subject"];
                
                
                if (cell.senderLabel.text.length == 0) {
                    cell.senderLabel.text = cell.senderEmail;
                }
                
                if (cell.senderLabel.text.length == 0) {
                    cell.senderLabel.text = @"No Recipient";
                }
                
                
                //Message ID
                cell.messageID = self.inboxData[indexPath.row][@"message_id"];
                
                
                NSNumber *unixDate = [[self.inboxData objectAtIndex:indexPath.row] objectForKey:@"date"];
                NSString *dateString = [self dateLabelForUnixDate:[unixDate doubleValue]];
                cell.timeLabel.text = dateString;
                
                
                //Fix Labels Depending on Filters
                if ([self.filter isEqualToString:@"Imp"]) {
                    if ([cell.importantLabel.text isEqualToString:@"Not Imp"]) {
                        [cell.importantLabel setText:@"Imp"];
                        [cell.importantLabel setBackgroundColor:[UIColor colorWithRed:1 green:0.2 blue:0.3 alpha:1.0f]];
                    }
                }
                
            }
        }
        else {
            //If Searching
            if (self.searchData.count > indexPath.row) {
                
                
                //Folders
                folders = [[self.inboxData objectAtIndex:indexPath.row] objectForKey:@"folders"];
                
                cell.importantLabel.text = [self labelTextForMessageWithFolders:folders];
                if ([cell.importantLabel.text isEqualToString:@"Draft"]) {
                    cell.importantLabel.backgroundColor = [UIColor colorWithRed:0.6 green:0.3 blue:0.6 alpha:1];
                }
                
                else if ([cell.importantLabel.text isEqualToString:@"Sent"]) {
                    cell.importantLabel.backgroundColor = [UIColor colorWithRed:0.3 green:0.8 blue:0.6 alpha:1];
                }
                
                else if ([cell.importantLabel.text isEqualToString:@"Imp"]) {
                    cell.importantLabel.backgroundColor = [UIColor colorWithRed:1 green:0.2 blue:0.3 alpha:1];
                }
                
                else {
                    //Not Imp
                    cell.importantLabel.backgroundColor = [UIColor colorWithRed:0.1 green:0.2 blue:0.3 alpha:1.0f];
                }
                
                
                cell.senderEmail = [[[[self.searchData objectAtIndex:indexPath.row] objectForKey:@"addresses"] objectForKey:@"from"] objectForKey:@"email"];
                
                //If Email is Sent
                if ([cell.importantLabel.text isEqualToString:@"Sent"]) {
                    senderName = [[[[[self.searchData objectAtIndex:indexPath.row] objectForKey:@"addresses"] objectForKey:@"to"] objectAtIndex:0] objectForKey:@"name"];
                    if ([senderName isEqual:NULL]) {
                        senderName = [[[[[self.searchData objectAtIndex:indexPath.row] objectForKey:@"addresses"] objectForKey:@"to"] objectAtIndex:0] objectForKey:@"email"];
                    }
                    cell.senderEmail = [[[[[self.searchData objectAtIndex:indexPath.row] objectForKey:@"addresses"] objectForKey:@"to"] firstObject] objectForKey:@"email"];
                }
                else {
                    senderName = [[[[self.searchData objectAtIndex:indexPath.row] objectForKey:@"addresses"] objectForKey:@"from"] objectForKey:@"name"];
                }
                
                cell.senderName = senderName;
                cell.senderLabel.text = senderName;
                cell.subjectLabel.text = [[self.searchData objectAtIndex:indexPath.row] objectForKey:@"subject"];
                
                
                if (cell.senderLabel.text.length == 0) {
                    cell.senderLabel.text = cell.senderEmail;
                }
                
                if (cell.senderLabel.text.length == 0) {
                    cell.senderLabel.text = @"No Recipient";
                }
                
                
                //Message ID
                cell.messageID = self.searchData[indexPath.row][@"message_id"];
                
                
                NSNumber *unixDate = [[self.searchData objectAtIndex:indexPath.row] objectForKey:@"date"];
                NSString *dateString = [self dateLabelForUnixDate:[unixDate doubleValue]];
                cell.timeLabel.text = dateString;
                
                
                //Fix Labels Depending on Filters
                if ([self.filter isEqualToString:@"Imp"]) {
                    if ([cell.importantLabel.text isEqualToString:@"Not Imp"]) {
                        [cell.importantLabel setText:@"Imp"];
                        [cell.importantLabel setBackgroundColor:[UIColor colorWithRed:1 green:0.2 blue:0.3 alpha:1.0f]];
                    }
                }
                
            }
        }
        
        
        
        
        
        
        //        //Images
        //        NSArray *senderNameArray = [senderName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        //        if (senderNameArray.count > 1) {
        //            cell.imageLabel.text = [NSString stringWithFormat:@"%@%@", [senderNameArray[0] substringToIndex:1], [senderNameArray[1] substringToIndex:1]];
        //        }
        //        else {
        //            cell.imageLabel.text = [senderName substringToIndex:1];
        //        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //Do background work
            //            NSLog(@"getting Image at Index %ld", indexPath.row);
            //            UIImage *contactImage = [self getImageForCellAtIndexPath:indexPath];
            dispatch_async(dispatch_get_main_queue(), ^{
                //Update UI
                //                cell.contactImageView.image = contactImage;
                //                cell.imageLabel.hidden = YES;
            });
        });
        
        
        
        // Selection Color
        if (indexPath.section == 0) {
            UIView *selectionColor = [[UIView alloc] init];
            selectionColor.backgroundColor = [UIColor clearColor];
            cell.selectedBackgroundView = selectionColor;
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        
        else {
            UIView *selectionColor = [[UIView alloc] init];
            selectionColor.backgroundColor = [UIColor colorWithRed:0.8 green:0.2 blue:0.3 alpha:1];
            cell.selectedBackgroundView = selectionColor;
        }
        
        return cell;
    }
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
    
    for (NSString* item in flags)
    {
        if ([item rangeOfString:@"Seen" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            return YES;
        }
    }
    
    return NO;
}


-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return @[];
    }
    else {
        UITableViewRowAction *viewButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"View" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                            {
                                                //Action for Button Here
                                                //                                               [self request:indexPath];
                                            }];
        [viewButton setBackgroundColor:[UIColor colorWithRed:0.2 green:0.7 blue:0.9 alpha:1.0]];
        
        UITableViewRowAction *shareButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Share" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                             {
                                                 //Action for Button Here
                                                 //                                             [self share:indexPath];
                                             }];
        [shareButton setBackgroundColor:[UIColor colorWithRed:0.9 green:0.2 blue:0.6 alpha:1.0]];
        
        //        return @[viewButton, shareButton];
        return @[];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // you need to implement this method too or nothing will work:
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"Selected Row at Index %ld, Section %ld", indexPath.row, indexPath.section);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    InboxTableViewCell *cell = (InboxTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        // Do Nothing
        
    }
    
    else {
        //Set Flag as Seen / Read
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSDictionary *params = @{@"seen":@(1)};
            [[[ContextIOAPIInformation getAPIClient] updateFlagsForMessageWithID:cell.messageID params:params] executeWithSuccess:^(NSDictionary *responseDict) {
                NSLog(@"Message with ID %@ marked as seen.", cell.messageID);
                cell.readLabel.hidden = YES;
            }
                                                                                                                          failure:^(NSError *error) {
                                                                                                                              NSLog(@"Message with ID %@ could not be marked as seen. Error %@", cell.messageID, error.localizedDescription);
                                                                                                                          }];
        });
        
        
        // Present ThreadViewController
        NSLog(@"Push Thread View Controller with Contact: %@", self.selectedFromEmail);
        MessageViewController *messageVC = (MessageViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"messageVC"];
        messageVC.messageID = cell.messageID;
        [self.navController pushViewController:messageVC animated:YES];
    }
    
}

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
        NSLog(@"Loading Messages with Offset: %ld", self.loadedMessages);
        self.isLoadingMoreData = YES;
        [self getMessagesWithOffset:self.loadedMessages];
    }
}

#pragma mark - Keyboard

-(IBAction)returnKeyPressed:(id)sender {
    [sender resignFirstResponder];
    
    self.isSearching = YES;
    InboxTableViewCell *cell = [self.inboxTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITextField *searchField = (UITextField *)[cell viewWithTag:94];
    NSString *searchQuery = searchField.text;
    NSLog(@"Search Query: %@", searchQuery);
    
    if (searchQuery.length == 0) {
        [self.inboxTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        [self textFieldShouldClear:searchField];
    }
    else {
        
        for (int i=0; i<[self.inboxData count]; i++) {
            NSString *senderName = [[[[self.inboxData objectAtIndex:i] objectForKey:@"addresses"] objectForKey:@"from"] objectForKey:@"name"];
            NSString *senderEmail = [[[[self.inboxData objectAtIndex:i] objectForKey:@"addresses"] objectForKey:@"from"] objectForKey:@"email"];
            NSString *subject = [[self.inboxData objectAtIndex:i] objectForKey:@"subject"];
            
            BOOL searchCondition = [senderName rangeOfString:searchQuery options:NSCaseInsensitiveSearch].location != NSNotFound;
            searchCondition = searchCondition || [senderEmail rangeOfString:searchQuery options:NSCaseInsensitiveSearch].location != NSNotFound;
            searchCondition = searchCondition || [subject rangeOfString:searchQuery options:NSCaseInsensitiveSearch].location != NSNotFound;
            
            if (searchCondition) {
                [self.searchData addObject:[self.inboxData objectAtIndex:i]];
                //                NSLog(@"Added Object %@", [self.inboxData objectAtIndex:i]);
            }
        }
        
        [self.inboxTableView reloadData];
    }
}



#pragma mark Tab Actions
-(IBAction)tabButtonPressed:(id)sender {
    if (self == self.navigationController.topViewController) {
        switch ([sender tag]) {
            case 0:
                // messages - do nothing
                break;
            case 1:
                // attachments
                [self performSegueWithIdentifier:@"showAttachments" sender:self];
                //                AttachmentsViewController *attachmentsVC = (AttachmentsViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"attachmentsVC"];
                break;
            case 2:
                // photos
                [self performSegueWithIdentifier:@"showPhotos" sender:self];
                //                AttachmentsViewController *attachmentsVC = (AttachmentsViewController *) [self.storyboard instantiateViewControllerWithIdentifier:@"attachmentsVC"];
                break;
            default:
                break;
        }
        
    }
}


-(IBAction)showComposeVC:(id)sender {
    [self performSegueWithIdentifier:@"showCompose" sender:self];
}

-(void)getMessages {
    [self getMessagesWithOffset:0];
    
}

-(IBAction)checkInternet:(id)sender {
    if (![self isInternetConnection]) {
        [self.delegate noInternetConnection];
    }
}

-(BOOL)isInternetConnection {
    //   Check for Internet Connection
    NSString *connect = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.apple.com"]] encoding:NSUTF8StringEncoding error:nil];
    //    NSLog(@"%@", connect);
    if (connect == NULL) {
        //No Internet Connection
        return FALSE;
    }
    else {
        return TRUE;
    }
    
}

-(void)getMessagesWithOffset:(int)offset {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"getting messages...");
        [self checkInternet:nil];
        self.isLoadingMoreData = YES;
        int limit = 100;
        NSDictionary *params = @{
                                 @"limit": @(limit),
                                 @"offset": @(offset),
                                 @"include_flags" : @(1)
                                 };
        [[[ContextIOAPIInformation getAPIClient] getMessagesWithParams:params]
         executeWithSuccess:^(NSArray *responseDict) {
             NSLog(@"Successfully got %ld messages", responseDict.count);
             if (responseDict.count == 0) {
                 [self.delegate errorGettingMessages:@"Could not load messages. Please try again later."];
                 return;
             }
             if (offset == 0) {
                 self.messagesData = [responseDict mutableCopy];
             }
             else {
                 [self.messagesData addObjectsFromArray:responseDict];
             }
             self.isLoadingMoreData = NO;
             self.loadedMessages += 100;
             self.inboxData = [[NSArray arrayWithArray:self.messagesData] mutableCopy];
             //         NSLog(@"Inbox Data: %@", self.inboxData);
             [self applyFilter];
             [self saveData];
             [self.inboxTableView.pullToRefreshView stopAnimating];
         } failure:^(NSError *error) {
             NSLog(@"error getting messages: %@", error);
             self.isLoadingMoreData = YES;
             [self.delegate errorGettingMessages:error.localizedDescription];
         }];
        
    });
}



-(UIImage *)getImageForCellAtIndexPath:(NSIndexPath *)indexPath {
    NSString *fromEmail = [[[[self.messagesData objectAtIndex:indexPath.row] objectForKey:@"addresses"] objectForKey:@"from"] objectForKey:@"email"];
    NSString *contactImageURL = [[[[self.messagesData objectAtIndex:indexPath.row] objectForKey:@"person_info"] objectForKey:fromEmail] objectForKey:@"thumbnail"];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:contactImageURL]]];
    InboxTableViewCell *cell = (InboxTableViewCell *)[self.inboxTableView cellForRowAtIndexPath:indexPath];
    cell.imageLabel.hidden = NO;
    //    NSLog(@"got Image at Index %ld", indexPath.row);
    return image;
}

#pragma mark - Save Inbox Array

-(void)saveData{
    [[NSUserDefaults standardUserDefaults] setObject:self.messagesData forKey:@"inboxCache"];
}

-(void)loadData {
    self.messagesData = [[[NSUserDefaults standardUserDefaults] objectForKey:@"inboxCache"] mutableCopy];
    if (self.messagesData != NULL)
    {
        self.inboxData = [self.messagesData mutableCopy];
        NSLog(@"Load %ld items into inboxData", self.inboxData.count);
        [self applyFilter];
        [self.inboxTableView reloadData];
    }
}

-(void)clearData {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"inboxCache"];
}

#pragma mark - Text Field Delegate
-(void)textFieldDidBeginEditing:(nonnull UITextField *)textField {
    NSLog(@"TextFieldDidBeginEditing");
    self.isSearching = YES;
    [self.searchData removeAllObjects];
    //    [self.inboxTableView []
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
    [self.inboxTableView reloadData];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - BaseViewControllerDelegate

-(void)topBarTouched {
    if ([self numberOfSectionsInTableView:self.inboxTableView] > 0)
    {
        NSIndexPath* top = [NSIndexPath indexPathForRow:NSNotFound inSection:0];
        [self.inboxTableView scrollToRowAtIndexPath:top atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}


/*
 #pragma mark - Navigation
 
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 //  Get the new view controller using [segue destinationViewController].
 //  Pass the selected object to the new view controller.
 NSLog(@"Preparing for segue %@", [segue identifier]);
 ThreadViewController *threadVC = (ThreadViewController *) [segue destinationViewController];
 threadVC.threadID = self.selectedThreadID;
 
 }
 */


@end
