//
//  Utils.h
//  iRoll
//
//  Created by Steven Roebert on 20/02/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//

//#import <opencv/cv.h>

@interface Utils : NSObject

+ (UIImage *)maskImage:(UIImage *)image withMask:(UIImage *)maskImage;
+ (UIImage *)createImageWithColor:(UIColor *)backgroundColor width:(CGFloat)width height:(CGFloat)height;

//+ (IplImage *)createIplImageFromUIImage:(UIImage *)image;
//+ (IplImage *)createIplImageFromUIImage:(UIImage *)image width:(int)width height:(int)height 
//						keepAspectRatio:(BOOL)keepaspect;
//+ (UIImage *)imageFromIplImage:(IplImage *)image;

@end
