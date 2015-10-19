//
//  DraggableViewBackground.m
//  testing swiping
//
//  Created by Richard Kim on 8/23/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//

#import "DraggableViewBackground.h"

@implementation DraggableViewBackground{
    NSInteger cardsLoadedIndex; //%%% the index of the card you have loaded into the loadedCards array last
    NSMutableArray *loadedCards; //%%% the array of card loaded (change max_buffer_size to increase or decrease the number of cards this holds)
    
    UIButton* menuButton;
    UIButton* messageButton;
    UIButton* checkButton;
    UIButton* xButton;
    NSInteger cardsSeen;
}
//this makes it so only two cards are loaded at a time to
//avoid performance and memory costs
int MAX_BUFFER_SIZE = 3; //%%% max number of cards loaded at any given time, must be greater than 1
float CARD_HEIGHT = 270; //%%% height of the draggable card
float CARD_WIDTH = 300; //%%% width of the draggable card

@synthesize exampleCardLabels; //%%% all the labels I'm using as example data at the moment
@synthesize allCards;//%%% all the cards

- (id)initWithFrame:(CGRect)frame data:(NSMutableArray *)dataArray
{
    self = [super initWithFrame:frame];
    if (self) {
        CARD_WIDTH = self.frame.size.width - 20;
        [super layoutSubviews];
        [self setupView];
        loadedCards = [[NSMutableArray alloc] init];
        allCards = [[NSMutableArray alloc] init];
        cardsLoadedIndex = 0;
        exampleCardLabels = dataArray;
        cardsSeen = 0;
        [self loadCardsWithArray:dataArray];
    }
    return self;
}



//%%% sets up the extra buttons on the screen
-(void)setupView
{
#warning customize all of this.  These are just place holders to make it look pretty
    
    //Background Gradient
    [self setBackgroundColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.2 alpha:1.0]];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.1 green:0.1 blue:0.2 alpha:1] CGColor], (id)[[UIColor colorWithRed:0.1 green:0.3 blue:0.4 alpha:1] CGColor], nil];
    [self.layer insertSublayer:gradient atIndex:0];
    
    menuButton = [[UIButton alloc]initWithFrame:CGRectMake(17, 34, 30, 30)];
    [menuButton setImage:[UIImage imageNamed:@"menu-icon-30"] forState:UIControlStateNormal];
    messageButton = [[UIButton alloc]initWithFrame:CGRectMake(284, 34, 18, 18)];
    [messageButton setImage:[UIImage imageNamed:@"messageButton"] forState:UIControlStateNormal];
    xButton = [[UIButton alloc]initWithFrame:CGRectMake(60, 485, 59, 59)];
    [xButton setTitle:@"X" forState:UIControlStateNormal];
    [xButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [xButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [xButton.layer setCornerRadius:xButton.frame.size.height/2];
    [xButton.layer setBorderWidth:1.0f];
    
    //    [xButton setImage:[UIImage imageNamed:@"xButton"] forState:UIControlStateNormal];
    [xButton addTarget:self action:@selector(swipeLeft) forControlEvents:UIControlEventTouchUpInside];
    checkButton = [[UIButton alloc]initWithFrame:CGRectMake(200, 485, 59, 59)];
    //    [checkButton setImage:[UIImage imageNamed:@"checkButton"] forState:UIControlStateNormal];
    [checkButton addTarget:self action:@selector(swipeRight) forControlEvents:UIControlEventTouchUpInside];
    [xButton setTitle:@"√" forState:UIControlStateNormal];
    [xButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [xButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [xButton.layer setCornerRadius:xButton.frame.size.height/2];
    [xButton.layer setBorderWidth:1.0f];
    
    
    self.counterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 50, self.frame.size.width, 20)];
    [self.counterLabel setText:@""];
    [self.counterLabel setTextColor:[UIColor whiteColor]];
    [self.counterLabel setTextAlignment:NSTextAlignmentCenter];
    [self.counterLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
    //    [self.counterLabel setBackgroundColor:[UIColor greenColor]];
    
    self.finishedCardsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.frame.size.height - CARD_HEIGHT + 160)/2, self.frame.size.width, 20)];
    [self.finishedCardsLabel setText:@"You've seen all the highlights!"];
    [self.finishedCardsLabel setTextColor:[UIColor whiteColor]];
    [self.finishedCardsLabel setTextAlignment:NSTextAlignmentCenter];
    [self.finishedCardsLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f]];
    
    [self addSubview:self.counterLabel];
    [self addSubview:self.finishedCardsLabel];
    
    
    //    [self addSubview:menuButton];
    //    [self addSubview:messageButton];
    //    [self addSubview:xButton];
    //    [self addSubview:checkButton];
}

#warning include own card customization here!
//%%% creates a card and returns it.  This should be customized to fit your needs.
// use "index" to indicate where the information should be pulled.  If this doesn't apply to you, feel free
// to get rid of it (eg: if you are building cards from data from the internet)
-(DraggableView *)createDraggableViewWithDataAtIndex:(NSInteger)originalIndex
{
    
    NSInteger index = originalIndex;
    DraggableView *draggableView = [[DraggableView alloc] initWithFrame:CGRectMake((self.frame.size.width - CARD_WIDTH)/2, (self.frame.size.height - CARD_HEIGHT)/2 - (index*15), CARD_WIDTH, CARD_HEIGHT)];
    if (index > 0) {
        index = originalIndex % MAX_BUFFER_SIZE;
        [draggableView setFrame:CGRectMake((self.frame.size.width - CARD_WIDTH + (index*15))/2, (self.frame.size.height - CARD_HEIGHT)/2 - (index*15), CARD_WIDTH - (index*15), CARD_HEIGHT)];
    }
    index = originalIndex;
    
    // Populate with Data
    NSString *senderName = exampleCardLabels[index][@"addresses"][@"from"][@"name"];
    draggableView.senderNameLabel.text = senderName;
    draggableView.subjectLabel.text = exampleCardLabels[index][@"subject"];
    draggableView.messageID = exampleCardLabels[index][@"message_id"];
    
    NSDictionary *listHeaders = exampleCardLabels[index][@"list_headers"];
    if (listHeaders == NULL || [listHeaders objectForKey:@"list-unsubscribe"] == NULL) {
        draggableView.unsubscribeButton.hidden = YES;
    }
    else {
        
        NSString *unsubscribeString = exampleCardLabels[index][@"list_headers"][@"list-unsubscribe"];
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
                draggableView.unsubscribeButton.hidden = NO;
            }
            else {
                draggableView.unsubscribeButton.hidden = YES;
            }
        }

        draggableView.unsubscribeButton.tag = index;
        [draggableView.unsubscribeButton addTarget:self action:@selector(unsubscribeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }

    //Images
    NSArray *senderNameArray = [senderName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (senderNameArray.count > 1) {
        draggableView.senderImageLabel.text = [NSString stringWithFormat:@"%@%@", [senderNameArray[0] substringToIndex:1], [senderNameArray[1] substringToIndex:1]];
    }
    else {
        draggableView.senderImageLabel.text = [senderName substringToIndex:1];
    }
    draggableView.senderImageLabel.text = [draggableView.senderImageLabel.text uppercaseString];
    
    draggableView.delegate = self;
    //    draggableView.alpha = (1 - (index/10));
    if (index > 0) {
        draggableView.alpha = 0.25;
        draggableView.senderImageView.hidden = YES;
    }
    
    
    return draggableView;
}

//%%% loads all the cards and puts the first x in the "loaded cards" array
-(void)loadCardsWithArray:(NSMutableArray *)cardsArray
{
    exampleCardLabels = cardsArray;
    if([exampleCardLabels count] > 0) {
        NSInteger numLoadedCardsCap =(([exampleCardLabels count] > MAX_BUFFER_SIZE)?MAX_BUFFER_SIZE:[exampleCardLabels count]);
        //%%% if the buffer size is greater than the data size, there will be an array error, so this makes sure that doesn't happen
        
        //%%% loops through the exampleCardsLabels array to create a card for each label.  This should be customized by removing "exampleCardLabels" with your own array of data
        for (int i = 0; i<[exampleCardLabels count]; i++) {
            DraggableView* newCard = [self createDraggableViewWithDataAtIndex:i];
            [allCards addObject:newCard];
            
            if (i<numLoadedCardsCap) {
                //%%% adds a small number of cards to be loaded
                [loadedCards addObject:newCard];
            }
        }
        
        //%%% displays the small number of loaded cards dictated by MAX_BUFFER_SIZE so that not all the cards
        // are showing at once and clogging a ton of data
        for (int i = 0; i<[loadedCards count]; i++) {
            if (i>0) {
                [self insertSubview:[loadedCards objectAtIndex:i] belowSubview:[loadedCards objectAtIndex:i-1]];
            } else {
                [self addSubview:[loadedCards objectAtIndex:i]];
            }
            cardsLoadedIndex++; //%%% we loaded a card into loaded cards, so we have to increment
        }
        [self.counterLabel setText:[NSString stringWithFormat:@"%ld Messages", allCards.count]];
    }
}

#warning include own action here!
//%%% action called when the card goes to the left.
// This should be customized with your own action
-(void)cardSwipedLeft:(UIView *)card;
{
    //do whatever you want with the card that was swiped

    //Archive Message
    DraggableView *swipedCard = (DraggableView *)card;
    NSDictionary *params = @{@"add":@"MailApp/Archived",
                             @"remove":@"INBOX"};
    [[self.APIClient updateFoldersForMessageWithID:[NSString stringWithFormat:@"%@", swipedCard.messageID] params:params] executeWithSuccess:^(NSDictionary *responseDict) {
        NSLog(@"Message with ID %@ archived.", swipedCard.messageID);
    }
                                                                                                                                             failure:^(NSError *error) {
                                                                                                                                                 NSLog(@"Message with ID %@ could not be archived. Error %@", swipedCard.messageID, error);
                                                                                                                                             }];
    
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    
    if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
        
    }
    [self fixTopCard];
}

#warning include own action here!
//%%% action called when the card goes to the right.
// This should be customized with your own action
-(void)cardSwipedRight:(UIView *)card
{
    //do whatever you want with the card that was swiped
    DraggableView *swipedCard = (DraggableView *)card;
    
    
    //Do Nothing
    
//    [[self.APIClient updateMessageWithID:[NSString stringWithFormat:@"gm-%@", swipedCard.messageID] destinationFolder:@"\\Starred" params:nil] executeWithSuccess:^(NSDictionary *responseDict) {
//        NSLog(@"Message with ID %@ starred.", swipedCard.messageID);
//    }
//                                                                                                                                failure:^(NSError *error) {
//                                                                                                                                    NSLog(@"Message with ID %@ could not be starred. Error %@", swipedCard.messageID, error);
//                                                                                                                                }];
    
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    
    if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }
    [self fixTopCard];
}

//%%% when you hit the right button, this is called and substitutes the swipe
-(void)swipeRight
{
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeRight;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView rightClickAction];
}

//%%% when you hit the left button, this is called and substitutes the swipe
-(void)swipeLeft
{
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeLeft;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView leftClickAction];
}

-(void)fixTopCard {
    if (loadedCards.count > 0) {
        DraggableView *topCard = [loadedCards objectAtIndex:0];
        [topCard setFrame:CGRectMake((self.frame.size.width - CARD_WIDTH)/2, (self.frame.size.height - CARD_HEIGHT)/2, CARD_WIDTH, CARD_HEIGHT)];
        //        CAGradientLayer *gradient = [CAGradientLayer layer];
        //        gradient.frame = self.bounds;
        //        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.9 green:0.2 blue:0.3 alpha:1] CGColor], (id)[[UIColor colorWithRed:1 green:0.2 blue:0.6 alpha:1] CGColor], nil];
        //        [topCard.layer insertSublayer:gradient atIndex:1];
        topCard.alpha = 1;
        [topCard.senderImageView setHidden:NO];
        cardsSeen++;
        [self.counterLabel setText:[NSString stringWithFormat:@"%ld Messages Left", allCards.count - cardsSeen - 1]];
    }
}

-(void)showMessageWithID:(NSString *)messageID {
    [self.delegate showMessage:messageID];
}

-(IBAction)unsubscribeButtonPressed:(id)sender {
    NSString *unsubscribeString = exampleCardLabels[[sender tag]][@"list_headers"][@"list-unsubscribe"];
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
            [self.delegate unsubscribeToMailWithHeader:header];
        }
    }
    else {
        //Error
        NSLog(@"Could not unsubscribe");
    }
}




/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
