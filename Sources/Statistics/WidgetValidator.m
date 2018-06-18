//
//  WidgetValidator.m
//  iRoll
//
//  Created by Steven Roebert on 14/03/2010.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "WidgetValidator.h"


@implementation WidgetValidator {
    BOOL _R[64][64];
}

/**
 * The validation is solved using dynamic programming. Please see the paper
 * "An optimal strategy for Yahtzee" by James Glenn for more details.
 */
- (id)init {
	if ((self = [super init])) {
		for (int i = 0; i < 64; i++) {
			_R[i][0] = NO;
			_R[0][i] = YES;
		}
		
		for (int n = 1; n < 64; n++)
		{
			for (int s = 1; s < 64; s++)
			{
				BOOL result = NO;
				for (int k = 1; k <= 5; k++)
				{
					for (int x = 0; x < 6; x++)
					{
						if ((s & (1 << x)) == 0) {
							continue;
						}
						if (k*(x+1) > n) {
							break;
						}
						
						if (_R[n - k*(x+1)][s & ~(1 << x)]) {
							result = YES;
							break;
						}
					}
					
					if (result) {
						break;
					}
				}
				_R[n][s] = result;
			}
		}
		
		int counter = 0;
		for (int n = 0; n < 64; n++) {
			for (int s = 0; s < 64; s++) {
				if (!_R[n][s]) {
					counter++;
				}
			}
		}
	}
	return self;
}

- (BOOL)validateWidget:(Widget *)widget {
	int n = widget.totalUpperScore;
	int s = 0;
	for (int i = 0; i < 6; i++) {
		if ([widget getCategoryFilledForIndex:i]) {
			s |= (1 << i);
		}
	}
	return _R[n][s];
}

- (BOOL)validateWidgetHash:(int)hash {
	int n = (hash & 63);
	int s = 0;
	int categoryHash = (hash >> 6);
	for (int i = 0; i < 6; i++) {
		if (((categoryHash >> i) & 1) == 1) {
			s |= (1 << i);
		}
	}
	return _R[n][s];
}

@end
