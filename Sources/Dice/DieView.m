//
//  DiceLayer.m
//  iRoll
//
//  Created by Steven Roebert on 19/02/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//

#import "DieView.h"

@implementation DieView

- (void)setDieValue:(int)value {
	_dieValue = value;
	[self setNeedsDisplay];
}

/**
 * Draws the dots, based on the value.
 */
- (void)drawRect:(CGRect)rect {
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextSaveGState(ctx);
	CGContextSetRGBFillColor(ctx, 0, 0, 0, 1);
	CGContextSetRGBStrokeColor(ctx, 0.4, 0.4, 0.4, 1);
	
	// Scale the radius of the dots, based on the size of the die
	int radiusX = floor(self.bounds.size.width / 4.1);
	int radiusY = floor(self.bounds.size.height / 4.1);
	
	CGPoint center = CGPointMake(self.bounds.origin.x + self.bounds.size.width / 2.0, 
								 self.bounds.origin.y + self.bounds.size.height / 2.0);
	
	// Draw the dots based on the value
	switch (_dieValue) {
		case 4:
		case 5:
			CGContextFillEllipseInRect(ctx, 
									   CGRectMake(4, 4, radiusX, radiusY));
			CGContextFillEllipseInRect(ctx,
									   CGRectMake(self.bounds.size.width - 4 - radiusX, self.bounds.size.height - 4 - radiusY, radiusX, radiusY));
			
		case 2:
		case 3:
			CGContextFillEllipseInRect(ctx,
									   CGRectMake(4, self.bounds.size.height - 4 - radiusY, radiusX, radiusY));
			CGContextFillEllipseInRect(ctx,
									   CGRectMake(self.bounds.size.width - 4 - radiusX, 4, radiusX, radiusY));
			
			if (_dieValue == 2 || _dieValue == 4) {
				break;
			}
			
		case 1:
			CGContextFillEllipseInRect(ctx,
									   CGRectMake(center.x - radiusX / 2.0, center.y - radiusY / 2.0, radiusX, radiusY));
			break;
			
		case 6:
			CGContextFillEllipseInRect(ctx,
									   CGRectMake(6, 3, radiusX, radiusY));
			CGContextFillEllipseInRect(ctx,
									   CGRectMake(6, center.y - radiusY / 2.0, radiusX, radiusY));
			CGContextFillEllipseInRect(ctx,
									   CGRectMake(6, self.bounds.size.height - 3 - radiusY, radiusX, radiusY));
			
			CGContextFillEllipseInRect(ctx,
									   CGRectMake(self.bounds.size.width - 6 - radiusX, 3, radiusX, radiusY));
			CGContextFillEllipseInRect(ctx,
									   CGRectMake(self.bounds.size.width - 6 - radiusX, center.y - radiusY / 2.0, radiusX, radiusY));
			CGContextFillEllipseInRect(ctx,
									   CGRectMake(self.bounds.size.width - 6 - radiusX, self.bounds.size.height - 3 - radiusY, radiusX, radiusY));
			break;
	}
	
	CGContextRestoreGState(ctx);
}

@end
