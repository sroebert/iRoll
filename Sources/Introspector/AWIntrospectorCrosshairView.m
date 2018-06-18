//
//  AWIntrospectorCrosshairView.m
//  AWFoundation
//
//  Created by Steven Roebert on 19-11-2013.
//  Copyright (c) 2013 Steven Roebert. All rights reserved.
//

#if defined(DEBUG)

#import "AWIntrospectorCrosshairView.h"

@implementation AWIntrospectorCrosshairView

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_crossHairColor = [UIColor blueColor];
		self.opaque = NO;
	}
	return self;
}

- (void)setCrossHairColor:(UIColor *)crossHairColor {
    if (_crossHairColor == crossHairColor) {
        return;
    }
    
    _crossHairColor = crossHairColor;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	[_crossHairColor setFill];
    UIRectFill(CGRectMake(floor(CGRectGetWidth(self.bounds) / 2.0) - 1.0, 0, 2.0, CGRectGetHeight(self.bounds)));
    UIRectFill(CGRectMake(0, floor(CGRectGetHeight(self.bounds) / 2.0) - 1.0, CGRectGetWidth(self.bounds), 2.0));
}

@end

#endif
