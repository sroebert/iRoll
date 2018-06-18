//
//  UIDiceButton.m
//  iRoll
//
//  Created by Steven Roebert on 18/02/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DieButton.h"
#import "DieView.h"

@implementation DieButton {
    CAGradientLayer *_gradientLayer;
	DieView *_dieView;
	
	NSArray *_normalColors, *_selectedColors, *_highlightedColors;
	int _afterAnimationValue;
}

- (int)value {
	return _dieView.dieValue;
}

- (void)setDieValue:(int)newValue animated:(BOOL)animated {
	
	// If animated start the fadeout animation, hiding the dots
	if (animated && newValue != 0)
    {
		_afterAnimationValue = newValue;
		
        [self animateDieRoll:5 completion:^{
            
            _dieView.dieValue = _afterAnimationValue;
			[_delegate dieButtonAnimationCompleted:self];
        }];
	}
	// Otherwise just set the new value
	else {
		_dieView.dieValue = newValue;
	}
}

- (void)animateDieRoll:(NSUInteger)count completion:(void(^)(void))completion
{
    [UIView animateWithDuration:0.03 animations:^{
        _dieView.alpha = 0;
    } completion:^(BOOL finished) {
        
        _dieView.dieValue = rand()%6 + 1;
        [UIView animateWithDuration:0.03 animations:^{
            _dieView.alpha = 1;
            
        } completion:^(BOOL finished) {
            
            if (count == 1)
            {
                if (completion) {
                    completion();
                }
            }
            else {
                [self animateDieRoll:count - 1 completion:completion];
            }
        }];
    }];
}

- (void)awakeFromNib {
	// Create the gradient layer for the face background color
    _gradientLayer = [[CAGradientLayer alloc] init];
    [_gradientLayer setBounds:[self bounds]];
    [_gradientLayer setPosition:
	 CGPointMake([self bounds].size.width/2,
				 [self bounds].size.height/2)];
    [[self layer] insertSublayer:_gradientLayer atIndex:0];
	
	// Create the die layer for the dots
	_dieView = [[DieView alloc] initWithFrame:CGRectMake(0, 0,
		self.bounds.size.width, self.bounds.size.height)];
	_dieView.dieValue = 0;
	_dieView.opaque = NO;
	_dieView.userInteractionEnabled = NO;
	[self addSubview:_dieView];
	
	// Set the layer properties
    [[self layer] setCornerRadius:8.0f];
    [[self layer] setMasksToBounds:YES];
    [[self layer] setBorderWidth:0.5f];
	
	// Initialize the different state colors
	_normalColors = [[NSArray alloc] initWithObjects:
					(id)[[UIColor whiteColor] CGColor],
					(id)[[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1] CGColor], nil];
	_selectedColors = [[NSArray alloc] initWithObjects:
					  (id)[[UIColor colorWithRed:0.6 green:1 blue:0.6 alpha:1] CGColor],
					  (id)[[UIColor colorWithRed:0.4 green:0.7 blue:0.4 alpha:1] CGColor], nil];
	_highlightedColors = [[NSArray alloc] initWithObjects:
						 (id)[[UIColor colorWithRed:0.6 green:0.6 blue:1 alpha:1] CGColor],
						 (id)[[UIColor colorWithRed:0.4 green:0.4 blue:0.8 alpha:1] CGColor], nil];
	
	[_gradientLayer setColors:_normalColors];
}

- (void)setSelected:(BOOL)value {
	super.selected = value;
	
	if (value && !self.highlighted) {
		[_gradientLayer setColors:_selectedColors];
	}
	else if (self.highlighted) {
		[_gradientLayer setColors:_highlightedColors];
	}
	else {
		[_gradientLayer setColors:_normalColors];
	}
}

- (void)setHighlighted:(BOOL)value {
	super.highlighted = value;
	
	if (value) {
		[_gradientLayer setColors:_highlightedColors];
	}
	else if (self.selected) {
		[_gradientLayer setColors:_selectedColors];
	}
	else {
		[_gradientLayer setColors:_normalColors];
	}
}

@end
