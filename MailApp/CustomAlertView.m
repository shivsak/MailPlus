//
//  CustomAlertView.m
//  CustomAlertView
//
//  Created by Shiv Sakhuja on 6/4/15.
//  Copyright (c) 2015 Shiv Sakhuja. All rights reserved.
//

#import "CustomAlertView.h"

@implementation CustomAlertView

//Initialize
-(void)initWithTitle:(NSString *)titleText message:(NSString *)message firstButtonText:(NSString *)firstButtonTitle cancelButtonText:(NSString *)cancelButtonTitle withContainer:(UIViewController *)container {
    
    // Initialize Background View and Set Background Color
    self.customAlertBackground = [[UIView alloc] initWithFrame:container.view.frame];
    self.customAlertBackground.backgroundColor = [UIColor clearColor];
    
    // Set Width and Height
    [self setWidth:0 height:0]; //Will set width and height to 280, 200
    
    // Initialize Alert View and Set Background Color
    self.customAlert = [[UIView alloc] initWithFrame:CGRectMake((container.view.frame.size.width-self.width)/2, (container.view.frame.size.height-self.height)/2, self.width, self.height)];
    self.customAlert.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    self.customAlert.layer.cornerRadius = 8;
    
    // Add title label
    [self initializeTitle:titleText];
    
    // Add message label
    [self initializeMessage:message];
    
    // Add Button
    [self initializeFirstButton:firstButtonTitle];
    
    // Add Cancel Button
    [self initializeCancelButton:cancelButtonTitle];
    
    
    [container.view addSubview:self.customAlertBackground];
}

-(void)initializeTitle:(NSString *)alertTitle {
    self.customAlertTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, (self.customAlert.frame.size.width - 20), 40)];
    [self.customAlertTitle setTextAlignment:NSTextAlignmentCenter];
    [self.customAlertTitle setTextColor:[UIColor blackColor]];
    [self.customAlertTitle setBackgroundColor:[UIColor clearColor]];
    [self.customAlertTitle setFont:[UIFont fontWithName: @"HelveticaNeue-Medium" size: 19.0f]];
    [self.customAlertTitle setText:alertTitle];
}

-(void)initializeMessage:(NSString *)alertMessage {
    self.customAlertMessage = [[UILabel alloc] initWithFrame:CGRectMake(15, 50, (self.customAlert.frame.size.width - 30), 80)];
    [self.customAlertMessage setTextAlignment:NSTextAlignmentLeft];
    [self.customAlertMessage setTextColor:[UIColor darkGrayColor]];
    [self.customAlertMessage setBackgroundColor:[UIColor clearColor]];
    [self.customAlertMessage setFont:[UIFont fontWithName: @"HelveticaNeue" size: 15.0f]];
    self.customAlertMessage.numberOfLines = 5;
    [self.customAlertMessage setText:alertMessage];
}

-(void)initializeFirstButton:(NSString *)buttonText {
    if (buttonText != nil) {
        self.customAlertButton = [[UIButton alloc] initWithFrame:CGRectMake(10, (self.customAlertMessage.frame.size.height + self.customAlertMessage.frame.origin.y + 10), (self.customAlert.frame.size.width - 20), 40)];
        self.customAlertButton.backgroundColor = [UIColor colorWithRed:0.4 green:0.8 blue:0 alpha:1.0];
        self.customAlertButton.layer.cornerRadius = 4;
        [self.customAlertButton setTitle:buttonText forState:UIControlStateNormal];
        [self.customAlertButton.titleLabel setFont:[UIFont fontWithName: @"HelveticaNeue" size: 16.0f]];
        [self.customAlertButton.titleLabel setTextColor:[UIColor whiteColor]];
        [self.customAlertButton setEnabled:YES];
    }
}

-(void)initializeCancelButton:(NSString *)buttonText {
    // Add Cancel Button
    if (self.customAlertButton.titleLabel.text != nil) {
        self.customAlertButtonCancel = [[UIButton alloc] initWithFrame:CGRectMake(10, (self.customAlertButton.frame.size.height + self.customAlertButton.frame.origin.y + 10), (self.customAlert.frame.size.width - 20), 40)];
    }
    else {
        self.customAlertButtonCancel = [[UIButton alloc] initWithFrame:CGRectMake(10, (self.customAlertMessage.frame.size.height + self.customAlertMessage.frame.origin.y + 30), (self.customAlert.frame.size.width - 20), 40)];
        [self.customAlert setFrame:CGRectMake(self.customAlert.frame.origin.x, self.customAlert.frame.origin.y - 20, self.width, self.height - 40)];
    }
    self.customAlertButtonCancel.backgroundColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0];
    self.customAlertButtonCancel.layer.cornerRadius = 4;
    [self.customAlertButtonCancel setTitle:buttonText forState:UIControlStateNormal];
    [self.customAlertButtonCancel.titleLabel setFont:[UIFont fontWithName: @"HelveticaNeue" size: 16.0f]];
    [self.customAlertButtonCancel.titleLabel setTextColor:[UIColor whiteColor]];

}

// Show Custom Alert View
-(void)showAlert {
    [self.customAlertBackground addSubview:self.customAlert];
    [self.customAlert addSubview:self.customAlertTitle];
    [self.customAlert addSubview:self.customAlertMessage];
    [self.customAlert addSubview:self.customAlertButton];
    [self.customAlert addSubview:self.customAlertButtonCancel];
}

-(void)setTheme:(int)theme {
    switch (theme) {
        case 0:
            //Default Theme
            break;
            
        case 1:
            //Black Theme
            [self.customAlert setBackgroundColor:[UIColor blackColor]];
            [self.customAlertTitle setTextColor:[UIColor whiteColor]];
            [self.customAlertMessage setTextColor:[UIColor lightGrayColor]];
            
            break;
            
        case 2:
            //Blue Theme
            [self.customAlert setBackgroundColor:[UIColor colorWithRed:0.2 green:0.5 blue:0.9 alpha:1.0]];
            [self.customAlertTitle setTextColor:[UIColor whiteColor]];
            [self.customAlertMessage setTextColor:[UIColor whiteColor]];
            [self.customAlertButtonCancel setBackgroundColor:[UIColor redColor]];
            [self.customAlertButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [self.customAlertButton setBackgroundColor:[UIColor whiteColor]];
            break;
            
        case 3:
            //Royal Theme
            [self.customAlert setBackgroundColor:[UIColor purpleColor]];
            [self.customAlertTitle setTextColor:[UIColor whiteColor]];
            [self.customAlertMessage setTextColor:[UIColor whiteColor]];
            [self.customAlertButton setBackgroundColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.2 alpha:1.0]];
            [self.customAlertButtonCancel setBackgroundColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.2 alpha:1.0]];
            break;
            
        case 4:
            //Important Alert
            [self.customAlert setBackgroundColor:[UIColor blackColor]];
            [self.customAlertTitle setTextColor:[UIColor whiteColor]];
            [self.customAlertMessage setTextColor:[UIColor whiteColor]];
            [self.customAlertButton setBackgroundColor:[UIColor whiteColor]];
            [self.customAlertButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [self.customAlertButtonCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.customAlertButtonCancel setBackgroundColor:[UIColor redColor]];
            break;
            
        case 5:
            //Green for Go
            [self.customAlert setBackgroundColor:[UIColor colorWithRed:0.4 green:0.8 blue:0 alpha:1.0]];
            [self.customAlertTitle setTextColor:[UIColor whiteColor]];
            [self.customAlertMessage setTextColor:[UIColor whiteColor]];
            [self.customAlertButton setBackgroundColor:[UIColor whiteColor]];
            [self.customAlertButton setTitleColor:[UIColor colorWithRed:0.4 green:0.8 blue:0 alpha:1.0] forState:UIControlStateNormal];
            [self.customAlertButtonCancel setTitleColor:[UIColor colorWithRed:0.4 green:0.8 blue:0 alpha:1.0] forState:UIControlStateNormal];
            [self.customAlertButtonCancel setBackgroundColor:[UIColor whiteColor]];
            break;
            
            
        default:
            break;
    }
}

-(void)setPosition:(int)pos {
    switch (pos) {
            
        case 0:
            //Default Center Position
            break;
        case 1:
            //Top Alert
            
            [self.customAlertBackground setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
            [self.customAlert setFrame:CGRectMake(self.customAlertBackground.frame.origin.x, self.customAlertBackground.frame.origin.y, self.customAlertBackground.frame.size.width, self.height)];
            [self.customAlertTitle setFrame:CGRectMake(self.customAlertTitle.frame.origin.x, self.customAlertTitle.frame.origin.y, (self.customAlert.frame.size.width - 20), self.customAlertTitle.frame.size.height)];
            [self.customAlertMessage setFrame:CGRectMake(self.customAlertMessage.frame.origin.x, self.customAlertMessage.frame.origin.y, (self.customAlert.frame.size.width - 20), self.customAlertMessage.frame.size.height)];
            [self.customAlertButton setFrame:CGRectMake(self.customAlertButton.frame.origin.x, self.customAlertButton.frame.origin.y, (self.customAlert.frame.size.width - 20), self.customAlertButton.frame.size.height)];
            [self.customAlertButtonCancel setFrame:CGRectMake(self.customAlertButtonCancel.frame.origin.x, self.customAlertButtonCancel.frame.origin.y, (self.customAlert.frame.size.width - 20), self.customAlertButtonCancel.frame.size.height)];
            [self.customAlert.layer setCornerRadius:0];
            [self showAlert];
            break;
            
        default:
            break;
    }
}


//Set Alert View's Width and Height
-(void)setWidth:(int)width height:(int)height {
    if (width > 0 && height >= 10) {
        self.width = width;
        self.height = height;
    }
    else {
        self.width = 280;
        self.height = 260;
    }
    
    [self.customAlert setFrame:CGRectMake((self.customAlertBackground.frame.size.width-self.width)/2, (self.customAlertBackground.frame.size.height-self.height)/2, self.width, self.height)];
}

@end
