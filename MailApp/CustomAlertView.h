//
//  CustomAlertView.h
//  CustomAlertView
//
//  Created by Shiv Sakhuja on 6/4/15.
//  Copyright (c) 2015 Shiv Sakhuja. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomAlertView : UIView {
    
}

@property int width;
@property int height;

@property (nonatomic, retain) UIView *customAlertBackground;
@property (nonatomic, retain) UIView *customAlert;
@property (nonatomic, retain) UIButton *customAlertButton;
@property (nonatomic, retain) UIButton *customAlertButtonCancel;
@property (nonatomic, retain) UILabel *customAlertTitle;
@property (nonatomic, retain) UILabel *customAlertMessage;

-(void)initWithTitle:(NSString *)titleText message:(NSString *)message firstButtonText:(NSString *)firstButtonTitle cancelButtonText:(NSString *)cancelButtonTitle withContainer:(UIViewController *)container;
-(void)showAlert;

//Set CustomAlertView's width and height
-(void)setWidth:(int)width height:(int)height;
//Set Background View's Background Color
-(void)setBackgroundColor:(UIColor *)bgColor;
//Set Alert View's Background Color
-(void)setAlertBackgroundColor:(UIColor *)alertBgColor;


//Set Theme
-(void)setTheme:(int)theme;
-(void)setPosition:(int)pos;

@end
