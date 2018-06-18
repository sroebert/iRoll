//
//  DiceScanner.m
//  iRoll
//
//  Created by Steven Roebert on 27/02/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//

#import <math.h>
#import <opencv/cv.h>
#import "blob.h"
#import "BlobResult.h"
#import "DiceScanner.h"
#import "Utils.h"

@implementation DiceScanner

/**
 * Method for getting the contours for the dice in the image.
 */
+ (IplImage *)getDiceContoursForImage:(IplImage *)image {
	// Turn image into grayscale
	IplImage *grayScale = cvCreateImage(cvGetSize(image), IPL_DEPTH_8U, 1);
	cvCvtColor(image, grayScale, CV_BGR2GRAY);
	
	// Use the Canny Edge detector
	cvSmooth(grayScale, grayScale, CV_GAUSSIAN, 15, 15, 0, 0);
	cvCanny(grayScale, grayScale, 10, 40, 3);
	
	// Dilate the image, use flood fill and erode to leave only the contours of the dice
	IplConvKernel *element = cvCreateStructuringElementEx(5, 5, 0, 0, CV_SHAPE_ELLIPSE, 0);
	cvDilate(grayScale, grayScale, element, 1);
	cvFloodFill(grayScale, cvPoint(0, 0), CV_RGB(255, 255, 255), 
				CV_RGB(0, 0, 0), CV_RGB(255, 255, 255), NULL, 0, NULL);
	cvErode(grayScale, grayScale, element, 1);
	
	// Dilate again to make sure the edges do not contain holes
	IplConvKernel *element2 = cvCreateStructuringElementEx(3, 3, 0, 0, CV_SHAPE_ELLIPSE, 0);
	cvDilate(grayScale, grayScale, element2, 1);
	
	return grayScale;
}

+ (BOOL)rect:(CvRect)a includes:(CvRect)b {
	int aL = a.x;
	int aT = a.y;
	int aR = a.x + a.width;
	int aB = a.y + a.height;
	
	int bL = b.x;
	int bT = b.y;
	int bR = b.x + b.width;
	int bB = b.y + b.height;
	
	return	
	aL <= bL &&
	aR >= bR &&
	aT <= bT &&
	aB >= bB;
}

/**
 * Method for getting the location for each die in the image.
 */
+ (void)getDiceBlobs:(CBlobResult *)result forImage:(IplImage *)image  {
	
	// Dilate and find blobs
	IplImage *erodedImage = cvCreateImage(cvGetSize(image), IPL_DEPTH_8U, 1);
	cvCopy(image, erodedImage, 0);
	
	IplConvKernel *element = cvCreateStructuringElementEx(5, 5, 0, 0, CV_SHAPE_ELLIPSE, 0);
	cvErode(erodedImage, erodedImage, element, 2);
	
	*result = CBlobResult(erodedImage, 0, 255);
	cvReleaseImage(&erodedImage);
	
	// Remove small blobs
	result->Filter(*result, B_EXCLUDE, CBlobGetArea(), B_LESS, 1500);
	
	// Remove overlapping blobs, making sure dots are combined with their die
	for (int i = 0; i < result->GetNumBlobs(); i++) {
		CBlob *blob1 = result->GetBlob(i);
		for (int j = i + 1; j < result->GetNumBlobs(); j++) {
			CBlob *blob2 = result->GetBlob(j);
			
			if ([DiceScanner rect:blob1->GetBoundingBox() includes:blob2->GetBoundingBox()]) {
				result->Filter(*result, B_EXCLUDE, CBlobGetID(), B_EQUAL, blob2->GetID());
				j--;
			}
			else if ([DiceScanner rect:blob2->GetBoundingBox() includes:blob1->GetBoundingBox()]) {
				result->Filter(*result, B_EXCLUDE, CBlobGetID(), B_EQUAL, blob1->GetID());
				i--;
				break;
			}
		}
	}
}

/**
 * Fills each die using the flood fill algorithm, leaving only the dots of each die.
 */
+ (IplImage *)fillBlobs:(CBlobResult)blobResult forImage:(IplImage *)image {
	IplImage *filledBlobsImage = cvCreateImage(cvGetSize(image), IPL_DEPTH_8U, 1);
	cvCopy(image, filledBlobsImage, 0);
	
	// Flood fill each die
	for (int i = 0; i < 5 && i < blobResult.GetNumBlobs(); i++) {
		CBlob *currentBlob = blobResult.GetBlob(i);
		CvSeq* seq = currentBlob->GetConvexHull();
		CvPoint firstPoint = *((CvPoint*)cvGetSeqElem(seq, 0));

		cvFloodFill(filledBlobsImage, firstPoint, CV_RGB(255, 255, 255), 
					CV_RGB(0, 0, 0), CV_RGB(255, 255, 255), NULL, 0, NULL);
	}
	
	IplConvKernel *element = cvCreateStructuringElementEx(5, 5, 0, 0, CV_SHAPE_ELLIPSE, 0);
	
	// Remove noise and connect holes in dots by erotion and dilation
	cvErode(filledBlobsImage, filledBlobsImage, element, 2);
	cvDilate(filledBlobsImage, filledBlobsImage, element, 2);
	
	cvDilate(filledBlobsImage, filledBlobsImage, element, 1);
	cvErode(filledBlobsImage, filledBlobsImage, element, 1);
	
	return filledBlobsImage;
}

/**
 * Count the dots for each die in the image.
 */
+ (DiceRoll)countDiceDots:(CBlobResult)blobResult forImage:(IplImage *)image {
	
	int result[] = { 0, 0, 0, 0, 0 };
	for (int i = 0; i < 5 && i < blobResult.GetNumBlobs(); i++) {
		IplImage *singleBlobImage = cvCreateImage(cvGetSize(image), IPL_DEPTH_8U, 1);
		cvCopy(image, singleBlobImage, 0);
		
		// Fill all other blobs, so we do not count those dots
		for (int j = 0; j < 5 && j < blobResult.GetNumBlobs(); j++) {
			if (i == j) {
				continue;
			}
			
			CBlob *otherBlob = blobResult.GetBlob(j);
			otherBlob->FillBlob(singleBlobImage, CV_RGB(255, 255, 255), 0, 0);
		}
		
		// Get all the blobs in the die
		CBlobResult dotsResult = CBlobResult(singleBlobImage, 0, 255);
		
		// Filter noise
		dotsResult.Filter(dotsResult, B_EXCLUDE, CBlobGetAreaElipseRatio(), B_GREATER, 0.30);
		dotsResult.Filter(dotsResult, B_EXCLUDE, CBlobGetArea(), B_LESS, 50);
		
		// Remove overlapping blobs
		for (int u = 0; u < dotsResult.GetNumBlobs(); u++) {
			CBlob *blob1 = dotsResult.GetBlob(u);
			for (int v = u + 1; v < dotsResult.GetNumBlobs(); v++) {
				CBlob *blob2 = dotsResult.GetBlob(v);
				
				if ([DiceScanner rect:blob1->GetBoundingBox() includes:blob2->GetBoundingBox()]) {
					dotsResult.Filter(dotsResult, B_EXCLUDE, CBlobGetID(), B_EQUAL, blob2->GetID());
					v--;
				}
				else if ([DiceScanner rect:blob2->GetBoundingBox() includes:blob1->GetBoundingBox()]) {
					dotsResult.Filter(dotsResult, B_EXCLUDE, CBlobGetID(), B_EQUAL, blob1->GetID());
					u--;
					break;
				}
			}
		}
		
		// This must be the number for this die
		result[i] = dotsResult.GetNumBlobs();
		
		if (result[i] == 0) {
			result[i] = 1;
		}
		else if (result[i] > 6) {
			result[i] = 6;
		}
		
		cvReleaseImage(&singleBlobImage);
	}
	
	DiceRoll roll;
	for (int i = 0; i < DICE_COUNT; i++) {
		roll.dice[i] = result[i];
	}
	return roll;
}

/**
 * Get a dice roll from an image.
 */
+ (DiceRoll)scanDiceRollImage:(UIImage *)image {
	
	// Downsample the image, for quicker detection
	IplImage *iplImage = [Utils createIplImageFromUIImage:image
		width:640 height:640 keepAspectRatio:YES];
	
	// Perform edge detection and flood fill to leave only dice contours
	IplImage *contours = [DiceScanner getDiceContoursForImage:iplImage];
	
	// Get the dice blobs
	CBlobResult blobResult;
	[DiceScanner getDiceBlobs:&blobResult forImage:contours];
	
	// Fill each die to leave only the dots
	IplImage *filledDice = [DiceScanner fillBlobs:blobResult forImage:contours];
	
	// Calculate the number of dots for each die, to retrieve the dice roll
	DiceRoll roll = [DiceScanner countDiceDots:blobResult forImage:filledDice];
	
	cvReleaseImage(&iplImage);
	cvReleaseImage(&contours);
	cvReleaseImage(&filledDice);
	
	return roll;
}

/**
 * This method was used for testing purposes only.
 */
+ (UIImage *)scanDiceRollImageTest:(UIImage *)image
{
	IplImage *iplImage = [Utils createIplImageFromUIImage:image
													width:640 height:640 keepAspectRatio:YES];
	IplImage *contours = [DiceScanner getDiceContoursForImage:iplImage];
	
	CBlobResult blobResult;
	[DiceScanner getDiceBlobs:&blobResult forImage:contours];
	
	//NSLog(@"blobs: %d", blobResult.GetNumBlobs());
	
	IplImage *filledDice = [DiceScanner fillBlobs:blobResult forImage:contours];
	//DiceRoll roll = [DiceScanner countDiceDots:blobResult forImage:filledDice];
	
	IplImage *selectedReturnImage = filledDice;
	
	IplImage *returnImageRaw = cvCreateImage(cvGetSize(selectedReturnImage), IPL_DEPTH_8U, 3);
	cvCvtColor(selectedReturnImage, returnImageRaw, CV_GRAY2BGR);
	
	IplImage *returnImage = cvCreateImage(cvGetSize(returnImageRaw), IPL_DEPTH_8U, 4);
	cvCvtColor(returnImageRaw, returnImage, CV_BGR2RGBA);
	UIImage *returnUIImage = [Utils imageFromIplImage:returnImage];
	
	//NSLog(@"roll: %d %d %d %d %d", roll.dice[0], roll.dice[1], roll.dice[2], roll.dice[3], roll.dice[4]);
	 
	cvReleaseImage(&returnImageRaw);
	cvReleaseImage(&returnImage);
	
	cvReleaseImage(&iplImage);
	cvReleaseImage(&contours);
	cvReleaseImage(&filledDice);
	
	//UIImageWriteToSavedPhotosAlbum(returnUIImage, nil, nil, NULL);
	
	return returnUIImage;
}

@end
