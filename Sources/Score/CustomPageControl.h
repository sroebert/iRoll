//
//  CustomPageControl.h
//  iRoll
//
//  Created by Steven Roebert on 15/02/2011.
//  Copyright 2011 Steven Roebert. All rights reserved.
//

@interface CustomPageControl : UIPageControl

@property (nonatomic, assign) CGSize dotSize;
@property (nonatomic, assign) CGFloat dotPadding;
@property (nonatomic, strong) UIColor *defaultDotColor;
@property (nonatomic, strong) UIColor *selectedDotColor;

@end
