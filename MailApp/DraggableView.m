//
//  DraggableView.m
//  testing swiping
//
//  Created by Richard Kim on 5/21/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//
//  @cwRichardKim for updates and requests

#define ACTION_MARGIN 120 //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called
#define SCALE_STRENGTH 4 //%%% how quickly the card shrinks. Higher = slower shrinking
#define SCALE_MAX .93 //%%% upper bar for how much the card shrinks. Higher = shrinks less
#define ROTATION_MAX 1 //%%% the maximum rotation allowed in radians.  Higher = card can keep rotating longer
#define ROTATION_STRENGTH 320 //%%% strength of rotation. Higher = weaker rotation
#define ROTATION_ANGLE M_PI/8 //%%% Higher = stronger rotation angle


#import "DraggableView.h"
#import "MessageViewController.h"

@implementation DraggableView {
    CGFloat xFromCenter;
    CGFloat yFromCenter;
}

//delegate is instance of ViewController
@synthesize delegate;

@synthesize panGestureRecognizer;
@synthesize overlayView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        [self.viewMessageButton setHidden:NO];
        [self.senderImageView setHidden:NO];
        [self.senderNameLabel setHidden:NO];
        [self.subjectLabel setHidden:NO];
        [self.messageLabel setHidden:NO];
        [self.senderImageLabel setHidden:NO];
        [self.unsubscribeButton setHidden:NO];
        
        self.senderImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - 80)/2, 30, 80, 80)];
        self.senderImageView.image = [UIImage imageNamed:@"sample-girl.jpg"];
        [self.senderImageView.layer setCornerRadius:self.senderImageView.frame.size.width/2];
        [self.senderImageView.layer setMasksToBounds:YES];
        [self.senderImageView setContentMode:UIViewContentModeScaleAspectFill];
        
        self.senderImageLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - 80)/2, 30, 80, 80)];
        self.senderImageLabel.text = @"SS";
        [self.senderImageLabel setTextAlignment:NSTextAlignmentCenter];
        [self.senderImageLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:24.0]];
        self.senderImageLabel.textColor = [UIColor lightGrayColor];
        self.senderImageLabel.backgroundColor = [UIColor whiteColor];
        self.senderImageLabel.text = [self.senderImageLabel.text uppercaseString];
        [self.senderImageLabel.layer setCornerRadius:self.senderImageLabel.frame.size.width/2];
        [self.senderImageLabel.layer setMasksToBounds:YES];
        
        self.senderNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, self.senderImageView.frame.origin.y + self.senderImageView.frame.size.height + 20, self.frame.size.width-20, 20)];
        self.senderNameLabel.text = @"Shiv Sakhuja";
        [self.senderNameLabel setTextAlignment:NSTextAlignmentCenter];
        [self.senderNameLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0]];
        self.senderNameLabel.textColor = [UIColor whiteColor];
        
        self.subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.senderNameLabel.frame.origin.y+self.senderNameLabel.frame.size.height+10, self.frame.size.width-20, 20)];
        self.subjectLabel.text = @"Photographs from NYC";
        [self.subjectLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0]];
        [self.subjectLabel setTextAlignment:NSTextAlignmentCenter];
        self.subjectLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
        
        self.unsubscribeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 50, 20, 30, 30)];
        [self.unsubscribeButton setImage:[UIImage imageNamed:@"unsubscribe.png"] forState:UIControlStateNormal];

        
//        self.messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, self.subjectLabel.frame.origin.y+self.subjectLabel.frame.size.height+20, self.frame.size.width-40, 90)];
//        self.messageLabel.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
//        [self.messageLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]];
//        [self.messageLabel setTextAlignment:NSTextAlignmentJustified];
//        [self.messageLabel setNumberOfLines:5];
//        self.messageLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
        
        
        self.viewMessageButton = [[BorderedButton alloc] initWithFrame:CGRectMake(10, self.subjectLabel.frame.origin.y+self.subjectLabel.frame.size.height+30, self.frame.size.width-20, 40)];
        [self.viewMessageButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.8] forState:UIControlStateNormal];
        [self.viewMessageButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]];
        [self.viewMessageButton setTitle:@"View Message" forState:UIControlStateNormal];
        [self.viewMessageButton.layer setCornerRadius:self.viewMessageButton.frame.size.height/2];
        [self.viewMessageButton.layer setBorderWidth:1.0f];
        [self.viewMessageButton.layer setBorderColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.8].CGColor];
        [self.viewMessageButton addTarget:self action:@selector(showMessage:) forControlEvents:UIControlEventTouchUpInside];
        
        
        self.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
//        CAGradientLayer *gradient = [CAGradientLayer layer];
//        gradient.frame = self.bounds;
//        gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.3 green:0.7 blue:1 alpha:1] CGColor], (id)[[UIColor colorWithRed:0.4 green:0.9 blue:0.8 alpha:1] CGColor], nil];
//        [self.layer insertSublayer:gradient atIndex:0];
        
        
        panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(beingDragged:)];
        
        [self addGestureRecognizer:panGestureRecognizer];
        [self addSubview:self.senderNameLabel];
        [self addSubview:self.subjectLabel];
        [self addSubview:self.senderImageView];
        [self addSubview:self.messageLabel];
        [self addSubview:self.senderImageLabel];
        [self addSubview:self.viewMessageButton];
        [self addSubview:self.unsubscribeButton];
        
        overlayView = [[OverlayView alloc]initWithFrame:CGRectMake((self.frame.size.width-100)/2, (self.frame.size.height-100)/2, 100, 100)];
        overlayView.alpha = 0;
        [self addSubview:overlayView];
    }
    return self;
}

-(void)setupView
{
    // Gradient
    [self setBackgroundColor:[UIColor colorWithRed:0.9 green:0.2 blue:0.3 alpha:1.0]];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.9 green:0.2 blue:0.3 alpha:1] CGColor], (id)[[UIColor colorWithRed:1 green:0.3 blue:0.6 alpha:1] CGColor], nil];
    [self.layer insertSublayer:gradient atIndex:0];
    
    self.alpha = 1;
    self.layer.cornerRadius = 10.0f;
    self.layer.masksToBounds = YES;
    self.layer.shadowRadius = 3;
    self.layer.shadowOpacity = 0.2;
    self.layer.shadowOffset = CGSizeMake(1, 1);
}

-(IBAction)showMessage:(id)sender {
    NSLog(@"showMessageRunning");
    [delegate showMessageWithID:self.messageID];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

//%%% called when you move your finger across the screen.
// called many times a second
-(void)beingDragged:(UIPanGestureRecognizer *)gestureRecognizer
{
    //%%% this extracts the coordinate data from your swipe movement. (i.e. How much did you move?)
    xFromCenter = [gestureRecognizer translationInView:self].x; //%%% positive for right swipe, negative for left
    yFromCenter = [gestureRecognizer translationInView:self].y; //%%% positive for up, negative for down
    
    //%%% checks what state the gesture is in. (are you just starting, letting go, or in the middle of a swipe?)
    switch (gestureRecognizer.state) {
            //%%% just started swiping
        case UIGestureRecognizerStateBegan:{
            self.originalPoint = self.center;
            break;
        };
            //%%% in the middle of a swipe
        case UIGestureRecognizerStateChanged:{
            //%%% dictates rotation (see ROTATION_MAX and ROTATION_STRENGTH for details)
            CGFloat rotationStrength = MIN(xFromCenter / ROTATION_STRENGTH, ROTATION_MAX);
            
            //%%% degree change in radians
            CGFloat rotationAngel = (CGFloat) (ROTATION_ANGLE * rotationStrength);
            
            //%%% amount the height changes when you move the card up to a certain point
            CGFloat scale = MAX(1 - fabsf(rotationStrength) / SCALE_STRENGTH, SCALE_MAX);
            
            //%%% move the object's center by center + gesture coordinate
            self.center = CGPointMake(self.originalPoint.x + xFromCenter, self.originalPoint.y + yFromCenter);
            
            //%%% rotate by certain amount
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
            
            //%%% scale by certain amount
            CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
            
            //%%% apply transformations
            self.transform = scaleTransform;
            [self updateOverlay:xFromCenter];
            [self.viewMessageButton setHidden:YES];
            [self.senderImageView setHidden:YES];
            [self.senderNameLabel setHidden:YES];
            [self.subjectLabel setHidden:YES];
            [self.messageLabel setHidden:YES];
            [self.senderImageLabel setHidden:YES];
            [self.unsubscribeButton setHidden:YES];
            
            break;
        };
            //%%% let go of the card
        case UIGestureRecognizerStateEnded: {
            [self.viewMessageButton setHidden:NO];
            [self.senderImageView setHidden:NO];
            [self.senderNameLabel setHidden:NO];
            [self.subjectLabel setHidden:NO];
            [self.messageLabel setHidden:NO];
            [self.senderImageLabel setHidden:NO];
            [self.unsubscribeButton setHidden:NO];
            [self afterSwipeAction];
            break;
        };
        case UIGestureRecognizerStatePossible:break;
        case UIGestureRecognizerStateCancelled:break;
        case UIGestureRecognizerStateFailed:break;
    }
}

//%%% checks to see if you are moving right or left and applies the correct overlay image
-(void)updateOverlay:(CGFloat)distance
{
    if (distance > 0) {
        overlayView.mode = GGOverlayViewModeRight;
        
        
    }
    else if (distance < 0) {
        overlayView.mode = GGOverlayViewModeLeft;
    }
    else {
        //distance == 0
        
    }
    
    overlayView.alpha = MIN(fabsf(distance)/100, 1);
}

//%%% called when the card is let go
- (void)afterSwipeAction
{
    if (xFromCenter > ACTION_MARGIN) {
        [self rightAction];
    } else if (xFromCenter < -ACTION_MARGIN) {
        [self leftAction];
    } else { //%%% resets the card
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.center = self.originalPoint;
                             self.transform = CGAffineTransformMakeRotation(0);
                             overlayView.alpha = 0;
                         }];
    }
}

//%%% called when a swipe exceeds the ACTION_MARGIN to the right
-(void)rightAction
{
    CGPoint finishPoint = CGPointMake(500, 2*yFromCenter +self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedRight:self];
    
    NSLog(@"YES");
}

//%%% called when a swip exceeds the ACTION_MARGIN to the left
-(void)leftAction
{
    CGPoint finishPoint = CGPointMake(-500, 2*yFromCenter +self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedLeft:self];
    
    NSLog(@"NO");
}

-(void)rightClickAction
{
    CGPoint finishPoint = CGPointMake(600, self.center.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(1);
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedRight:self];
    
    NSLog(@"YES");
}

-(void)leftClickAction
{
    CGPoint finishPoint = CGPointMake(-600, self.center.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(-1);
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedLeft:self];
    
    NSLog(@"NO");
}



@end
