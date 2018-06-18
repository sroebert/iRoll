//
//  CustomPageControl.m
//  iRoll
//
//  Created by Steven Roebert on 15/02/2011.
//  Copyright 2011 Steven Roebert. All rights reserved.
//

#import "CustomPageControl.h"

@interface CustomPageControl () {
    NSInteger _visibleCurrentPage;
}

- (void)initProperties;

- (CGPoint)dotsOffsetForRect:(CGRect)rect;

- (CGRect)frameForDot:(NSInteger)dot offset:(CGPoint)offset;

@end


@implementation CustomPageControl

#pragma mark -
#pragma mark Initialization

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
		[self initProperties];
    }
    return self;
}

- (void)awakeFromNib
{
	[self initProperties];
}

- (void)initProperties
{
	_dotSize = CGSizeMake(6, 6);
	_dotPadding = 5;
	_visibleCurrentPage = 0;
	
	self.defaultDotColor = [UIColor colorWithWhite:1 alpha:0.3];
	self.selectedDotColor = [UIColor whiteColor];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	[self setNeedsDisplay];
}

#pragma mark -
#pragma mark Properties

- (void)setDotSize:(CGSize)value
{
	if (CGSizeEqualToSize(_dotSize, value)) {
		return;
	}
	
	_dotSize = value;
	[self setNeedsDisplay];
}

- (void)setDotPadding:(CGFloat)value
{
	if (_dotPadding == value) {
		return;
	}
	
	_dotPadding = value;
	[self setNeedsDisplay];
}

- (void)setDefaultDotColor:(UIColor *)value
{
	if (_defaultDotColor == value) {
		return;
	}
	
	_defaultDotColor = value;
	[self setNeedsDisplay];
}

- (void)setSelectedDotColor:(UIColor *)value
{
	if (_selectedDotColor == value) {
		return;
	}
	
	_selectedDotColor = value;
	[self setNeedsDisplay];
}

- (void)setNumberOfPages:(NSInteger)value
{
	[super setNumberOfPages:value];
	
	for (UIView *subview in self.subviews) {
		[subview removeFromSuperview];
	}
	
	[self setNeedsDisplay];
}

- (void)setCurrentPage:(NSInteger)value
{
	[super setCurrentPage:value];
	_visibleCurrentPage = value;
	[self setNeedsDisplay];
}

#pragma mark -
#pragma mark Drawing

- (void)updateCurrentPageDisplay
{
	[super updateCurrentPageDisplay];
	_visibleCurrentPage = self.currentPage;
	[self setNeedsDisplay];
}

- (CGPoint)dotsOffsetForRect:(CGRect)rect
{
	CGFloat dotWidthWithPadding = (_dotSize.width + 2 * _dotPadding);
	CGFloat dotsWidth = (dotWidthWithPadding * self.numberOfPages);
	return CGPointMake(floor((rect.size.width - dotsWidth) / 2.0), floor((rect.size.height - _dotSize.height) / 2.0));
}

- (CGRect)frameForDot:(NSInteger)dot offset:(CGPoint)offset
{
	CGFloat dotWidthWithPadding = (_dotSize.width + 2 * _dotPadding);
	return CGRectMake(offset.x + _dotPadding + (dot * dotWidthWithPadding), offset.y, _dotSize.width, _dotSize.height);
}

- (void)drawRect:(CGRect)rect
{
	if (!self.defersCurrentPageDisplay) {
		_visibleCurrentPage = self.currentPage;
	}
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGPoint offset = [self dotsOffsetForRect:rect];
	for (NSInteger i = 0; i < self.numberOfPages; i++)
	{
		CGRect dotFrame = [self frameForDot:i offset:offset];
		
		if (i == _visibleCurrentPage)
		{
			[_selectedDotColor setFill];
			CGContextFillEllipseInRect(ctx, dotFrame);
		}
		else
		{
			[_defaultDotColor setFill];
			CGContextFillEllipseInRect(ctx, dotFrame);
		}
	}
}

- (CGSize)sizeForNumberOfPages
{
	CGFloat dotWidthWithPadding = (_dotSize.width + 2 * _dotPadding);
	CGFloat dotsWidth = (dotWidthWithPadding * self.numberOfPages);
	return CGSizeMake(dotsWidth, _dotSize.height + 2 * _dotPadding);
}

@end
