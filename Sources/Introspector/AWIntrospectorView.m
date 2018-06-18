//
//  AWIntrospectorView.m
//  AWFoundation
//
//  Created by Steven Roebert on 19-11-2013.
//  Copyright (c) 2013 Steven Roebert. All rights reserved.
//

#if defined(DEBUG)

#import "AWIntrospectorView.h"
#import "AWIntrospectorCrosshairView.h"

@interface AWIntrospectorView () {
    BOOL _crosshairVisible;
    AWIntrospectorCrosshairView *_crosshairView;
    UILabel *_touchLocationLabel;
    
    BOOL _trackingTouch;
    CGPoint _touchLocation;
    
    UIView *_touchedViewIndicatorView;
}

@end

@implementation AWIntrospectorView

static char AWIntrospectorViewTouchedViewObserverContext;

#pragma mark -
#pragma mark Initialize

+ (NSArray *)touchedViewObserverKeyPaths {
    return @[ @"frame", @"center", @"bounds", @"superview", @"window" ];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _touchedViewIndicatorView = [[UIView alloc] init];
        _touchedViewIndicatorView.hidden = YES;
        _touchedViewIndicatorView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _touchedViewIndicatorView.layer.borderWidth = 1.0;
        _touchedViewIndicatorView.layer.borderColor = [UIColor redColor].CGColor;
        [self addSubview:_touchedViewIndicatorView];
        
        _crosshairView = [[AWIntrospectorCrosshairView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _crosshairView.alpha = 0;
        [self addSubview:_crosshairView];
        
        _touchLocationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 28)];
        _touchLocationLabel.alpha = 0;
        _touchLocationLabel.font = [UIFont boldSystemFontOfSize:12];
        _touchLocationLabel.backgroundColor = [UIColor blackColor];
        _touchLocationLabel.textAlignment = NSTextAlignmentCenter;
        _touchLocationLabel.textColor = [UIColor whiteColor];
        _touchLocationLabel.layer.cornerRadius = 10.0;
        _touchLocationLabel.clipsToBounds = YES;
        [self addSubview:_touchLocationLabel];
        
        self.opaque = NO;
    }
    return self;
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
    [[AWIntrospectorView touchedViewObserverKeyPaths] enumerateObjectsUsingBlock:^(NSString *keyPath, NSUInteger idx, BOOL *stop) {
        [_touchedView removeObserver:self forKeyPath:keyPath context:&AWIntrospectorViewTouchedViewObserverContext];
    }];
}

#pragma mark -
#pragma mark Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &AWIntrospectorViewTouchedViewObserverContext) {
        [self updateTouchedIndicatorView];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark -
#pragma mark Update

- (void)updateCrossHair {
    if (_trackingTouch != _crosshairVisible) {
        _crosshairVisible = _trackingTouch;
        _crosshairView.alpha = _trackingTouch ? 0.8 : 0.0;
        _touchLocationLabel.alpha = _trackingTouch ? 0.5 : 0.0;
    }
    
    if (_trackingTouch) {
        _crosshairView.center = _touchLocation;
        
        CGPoint windowPoint = [self convertPoint:_touchLocation toView:nil];
        _touchLocationLabel.text = [NSString stringWithFormat:@"%0.f, %0.f", floor(windowPoint.x), floor(windowPoint.y)];
        
        CGSize textSize = [_touchLocationLabel sizeThatFits:CGSizeZero];
        _touchLocationLabel.bounds = CGRectMake(0, 0, ceil(textSize.width) + 10, ceil(textSize.height) + 8);
        
        CGFloat textHalfWidth = CGRectGetWidth(_touchLocationLabel.bounds) / 2.0;
        CGPoint textCenterPoint = CGPointMake(_touchLocation.x, _touchLocation.y - 24);
        if (textCenterPoint.x - textHalfWidth < 5) {
            textCenterPoint.x = 5 + textHalfWidth;
        }
        else if (textCenterPoint.x + textHalfWidth > CGRectGetWidth(self.bounds) - 5) {
            textCenterPoint.x = CGRectGetWidth(self.bounds) - 5 - textHalfWidth;
        }
        
        if (textCenterPoint.y - CGRectGetHeight(_touchLocationLabel.bounds) < 5) {
            textCenterPoint.y = _touchLocation.y + 24;
        }
        
        _touchLocationLabel.center = textCenterPoint;
    }
}

- (void)updateTouchedIndicatorView {
    _touchedViewIndicatorView.hidden = ([_touchedView isKindOfClass:[UIWindow class]] || _touchedView.window ? NO : YES);
    if (!_touchedViewIndicatorView.hidden) {
        
        CGRect frame;
        if ([_touchedView isKindOfClass:[UIWindow class]]) {
            frame = [self.window convertRect:_touchedView.bounds fromWindow:(UIWindow *)_touchedView];
        }
        else {
            frame = [_touchedView convertRect:_touchedView.bounds toView:nil];
            frame = [self.window convertRect:frame fromWindow:_touchedView.window];
        }
        frame = [self convertRect:frame fromView:nil];
        
        _touchedViewIndicatorView.center = CGPointMake(CGRectGetMinX(frame) + CGRectGetWidth(frame) / 2.0, CGRectGetMinY(frame) + CGRectGetHeight(frame) / 2.0);
        _touchedViewIndicatorView.bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
    }
}

#pragma mark -
#pragma mark Properties

- (void)setOutlineRectangles:(NSArray *)outlineRectangles {
    _outlineRectangles = [outlineRectangles copy];
    [self setNeedsDisplay];
}

#pragma mark -
#pragma mark Touched View

- (void)setTouchedView:(UIView *)touchedView {
    if (_touchedView == touchedView) {
        return;
    }
    
    [[AWIntrospectorView touchedViewObserverKeyPaths] enumerateObjectsUsingBlock:^(NSString *keyPath, NSUInteger idx, BOOL *stop) {
        [_touchedView removeObserver:self forKeyPath:keyPath context:&AWIntrospectorViewTouchedViewObserverContext];
    }];
    
    _touchedView = touchedView;
    [self updateTouchedIndicatorView];
    
    [[AWIntrospectorView touchedViewObserverKeyPaths] enumerateObjectsUsingBlock:^(NSString *keyPath, NSUInteger idx, BOOL *stop) {
        [_touchedView addObserver:self forKeyPath:keyPath options:0 context:&AWIntrospectorViewTouchedViewObserverContext];
    }];
    
    [self bounceTouchedView];
}

- (void)bounceTouchedView {
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        _touchedViewIndicatorView.transform = CGAffineTransformMakeScale(1.1, 1.1);
    } completion:^(BOOL finished) {
        if (!finished) {
            return;
        }
        
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _touchedViewIndicatorView.transform = CGAffineTransformIdentity;
        } completion:NULL];
    }];
}

- (void)shakeTouchedView {
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        _touchedViewIndicatorView.transform = CGAffineTransformMakeTranslation(10, 0);
    } completion:^(BOOL finished) {
        if (!finished) {
            return;
        }
        
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _touchedViewIndicatorView.transform = CGAffineTransformMakeTranslation(-10, 0);
        } completion:^(BOOL finished2) {
            if (!finished2) {
                return;
            }
            
            [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                _touchedViewIndicatorView.transform = CGAffineTransformIdentity;
            } completion:NULL];
        }];
    }];
}

#pragma mark -
#pragma mark Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    _touchLocation = [touch locationInView:self];
    _trackingTouch = YES;
    [self updateCrossHair];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!_trackingTouch) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    _touchLocation = [touch locationInView:self];
    [self updateCrossHair];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!_trackingTouch) {
        return;
    }
    
    _trackingTouch = NO;
    [self updateCrossHair];
    
    UITouch *touch = [touches anyObject];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGPoint location = [touch locationInView:window];
    
    self.touchedView = [window hitTest:location withEvent:event];
    if ([_delegate respondsToSelector:@selector(introspectorView:didChangeTouchedView:)]) {
        [_delegate introspectorView:self didChangeTouchedView:_touchedView];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!_trackingTouch) {
        return;
    }
    
    _trackingTouch = NO;
    [self updateCrossHair];
}

#pragma mark - Draw Outlines

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();

    [_outlineRectangles enumerateObjectsUsingBlock:^(NSValue *value, NSUInteger idx, BOOL *stop) {
        UIColor *randomColor = [UIColor colorWithRed:(arc4random() % 256) / 256.0f
                                               green:(arc4random() % 256) / 256.0f
                                                blue:(arc4random() % 256) / 256.0f
                                               alpha:1.0f];
        [randomColor set];
        CGRect valueRect = [value CGRectValue];
        valueRect = CGRectMake(valueRect.origin.x + 0.5f,
                               valueRect.origin.y + 0.5f,
                               valueRect.size.width - 1.0f,
                               valueRect.size.height - 1.0f);
        CGContextStrokeRect(context, valueRect);
    }];
}

@end

#endif
