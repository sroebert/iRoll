//
//  Utils.m
//  iRoll
//
//  Created by Steven Roebert on 20/02/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//

#import "Utils.h"

@implementation Utils

/**
 * Create a UIImage from an existing image using a mask.
 */
+ (UIImage *)maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
	
	CGImageRef maskRef = maskImage.CGImage; 
	
	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
										CGImageGetHeight(maskRef),
										CGImageGetBitsPerComponent(maskRef),
										CGImageGetBitsPerPixel(maskRef),
										CGImageGetBytesPerRow(maskRef),
										CGImageGetDataProvider(maskRef), NULL, false);
	
	CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
	CGImageRelease(mask);
	
	UIImage *maskedImage;
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
		maskedImage = [UIImage imageWithCGImage:masked scale:[UIScreen mainScreen].scale orientation:image.imageOrientation];
	}
	else {
		maskedImage = [UIImage imageWithCGImage:masked];
	}
	CGImageRelease(masked);
	
	return maskedImage;
}

/**
 * Create a UIImage with a specific background color, width and height.
 */
+ (UIImage *)createImageWithColor:(UIColor *)backgroundColor width:(CGFloat)width height:(CGFloat)height {
	
	if (&UIGraphicsBeginImageContextWithOptions != NULL) {
		UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, 0);
	}
	else {
		UIGraphicsBeginImageContext(CGSizeMake(width, height));
	}
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	UIGraphicsPushContext(context);								
	
	[backgroundColor set];
	UIRectFill(CGRectMake(0, 0, width, height));
	
	UIGraphicsPopContext();								
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}

/**
 * Create an IplImage from a UIImage.
 */
//+ (IplImage *)createIplImageFromUIImage:(UIImage *)image {
//	return [Utils createIplImageFromUIImage:image
//		width:image.size.width height:image.size.height keepAspectRatio:NO];
//}

/**
 * Create an IplImage from a UIImage. Also resizes the image to a specific width and height,
 * possibly keeping the aspect ratio of the original image.
 */
//+ (IplImage *)createIplImageFromUIImage:(UIImage *)image width:(int)width height:(int)height
//						keepAspectRatio:(BOOL)keepAspect {
//	
//	// If the aspect ratio must be kept, make sure the width and height are changed to make this
//	// happen
//	if (keepAspect) {
//		int finalWidth = (int)((height * image.size.width) / image.size.height);
//		int finalHeight = (int)((width * image.size.height) / image.size.width);
//		
//		if (width > finalWidth) {
//			width = finalWidth;
//		}
//		else {
//			height = finalHeight;
//		}
//	}
//	
//	// Getting CGImage from UIImage
//	CGImageRef imageRef = image.CGImage;
//	
//	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//	
//	// Creating temporal IplImage for drawing
//	IplImage *iplimage = cvCreateImage(cvSize(width, height), IPL_DEPTH_8U, 4);
//	
//	// Creating CGContext for temporal IplImage
//	CGContextRef contextRef = CGBitmapContextCreate(
//		iplimage->imageData, iplimage->width, iplimage->height,
//		iplimage->depth, iplimage->widthStep,
//		colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
//	
//	// Drawing CGImage to CGContext
//	CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), imageRef);
//	
//	CGContextRelease(contextRef);
//	CGColorSpaceRelease(colorSpace);
//	
//	// Creating result IplImage
//	IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
//	cvCvtColor(iplimage, ret, CV_RGBA2BGR);
//	cvReleaseImage(&iplimage);
//	
//	return ret;
//}

/**
 * Create a UIImage from an IplImage.
 */
//+ (UIImage *)imageFromIplImage:(IplImage *)image {
//	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//	
//	// Allocating the buffer for CGImage
//	NSData *data = [NSData dataWithBytes:image->imageData length:image->imageSize];
//	CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
//	
//	// Creating CGImage from chunk of IplImage
//	CGImageRef imageRef = CGImageCreate(
//		image->width, image->height,
//		image->depth, image->depth * image->nChannels, image->widthStep,
//		colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault,
//		provider, NULL, false, kCGRenderingIntentDefault);
//	
//	// Getting UIImage from CGImage
//	UIImage *ret;
//	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
//		ret = [UIImage imageWithCGImage:imageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
//	}
//	else {
//		ret = [UIImage imageWithCGImage:imageRef];
//	}
//	
//	CGImageRelease(imageRef);
//	CGDataProviderRelease(provider);
//	CGColorSpaceRelease(colorSpace);
//	return ret;
//}

@end
