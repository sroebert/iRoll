//
//  DiceScanner.h
//  iRoll
//
//  Created by Steven Roebert on 27/02/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//
//	This class uses OpenCV for detection of die faces from UIImages.
//

#import "DiceRoll.h"

@interface DiceScanner : NSObject

+ (DiceRoll)scanDiceRollImage:(UIImage *)image;
+ (UIImage *)scanDiceRollImageTest:(UIImage *)image;

@end
