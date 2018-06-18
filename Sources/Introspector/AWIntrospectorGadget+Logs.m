//
//  AWIntrospectorGadget+Logs.m
//  AWFoundation
//
//  Created by Ester on 21/05/13.
//  Copyright (c) 2013 Steven Roebert. All rights reserved.
//

#if defined(DEBUG)

#import "AWIntrospectorGadget+Logs.h"
#import "AWIntrospectorGadget+Descriptions.h"

@implementation AWIntrospectorGadget (Logs)

#pragma mark - Log propperties for view

- (void)logProppertiesForView:(UIView *)view {
    Class viewClass = [view class];
	NSString *className = [NSString stringWithFormat:@"%@", viewClass];
	
	NSMutableString *outputString = [NSMutableString stringWithFormat:@"\n\n** %@", className];
	
	// list the class heirachy
	Class superClass = [viewClass superclass];
	while (superClass)
	{
		[outputString appendFormat:@" : %@", superClass];
		superClass = [superClass superclass];
	}
	[outputString appendString:@" ** \n"];
    
	// dump properties of class and super classes, up to UIView
	NSMutableString *propertyString = [NSMutableString string];
	
	Class inspectClass = viewClass;
	while (inspectClass)
	{
		NSMutableString *objectString = [NSMutableString string];
		[objectString appendFormat:@"\n  ** %@ properties **\n", inspectClass];
		
        // print out generic uiview properties
        [objectString appendFormat:@"    tag: %i\n", view.tag];
        [objectString appendFormat:@"    frame: %@ | ", NSStringFromCGRect(view.frame)];
        [objectString appendFormat:@"bounds: %@ | ", NSStringFromCGRect(view.bounds)];
        [objectString appendFormat:@"center: %@\n", NSStringFromCGPoint(view.center)];
        [objectString appendFormat:@"    transform: %@\n", NSStringFromCGAffineTransform(view.transform)];
        [objectString appendFormat:@"    autoresizingMask: %@\n", [self describeProperty:@"autoresizingMask" value:[NSNumber numberWithInt:view.autoresizingMask]]];
        [objectString appendFormat:@"    autoresizesSubviews: %@\n", (view.autoresizesSubviews) ? @"YES" : @"NO"];
        [objectString appendFormat:@"    contentMode: %@ | ", [self describeProperty:@"contentMode" value:[NSNumber numberWithInt:view.contentMode]]];
        [objectString appendFormat:@"    backgroundColor: %@\n", [self describeColor:view.backgroundColor]];
        [objectString appendFormat:@"    alpha: %.2f | ", view.alpha];
        [objectString appendFormat:@"opaque: %@ | ", (view.opaque) ? @"YES" : @"NO"];
        [objectString appendFormat:@"hidden: %@ | ", (view.hidden) ? @"YES" : @"NO"];
        [objectString appendFormat:@"clips to bounds: %@ | ", (view.clipsToBounds) ? @"YES" : @"NO"];
        [objectString appendFormat:@"clearsContextBeforeDrawing: %@\n", (view.clearsContextBeforeDrawing) ? @"YES" : @"NO"];
        [objectString appendFormat:@"    userInteractionEnabled: %@ | ", (view.userInteractionEnabled) ? @"YES" : @"NO"];
        [objectString appendFormat:@"multipleTouchEnabled: %@\n", (view.multipleTouchEnabled) ? @"YES" : @"NO"];
        [objectString appendFormat:@"    gestureRecognizers: %@\n", (view.gestureRecognizers) ? [view.gestureRecognizers description] : @"nil"];
		
        
		
		[propertyString insertString:objectString atIndex:0];
		
		if (inspectClass == UIView.class)
		{
			break;
		}
        
		inspectClass = [inspectClass superclass];
	}
	
	[outputString appendString:propertyString];
	
	// list targets if there are any
	if ([view respondsToSelector:@selector(allTargets)])
	{
		[outputString appendString:@"\n  ** Targets & Actions **\n"];
		UIControl *control = (UIControl *)view;
		UIControlEvents controlEvents = [control allControlEvents];
		NSSet *allTargets = [control allTargets];
		[allTargets enumerateObjectsUsingBlock:^(id target, BOOL *stop)
		 {
			 NSArray *actions = [control actionsForTarget:target forControlEvent:controlEvents];
			 [actions enumerateObjectsUsingBlock:^(id action, NSUInteger idx, BOOL *stop2)
			  {
				  [outputString appendFormat:@"    target: %@ action: %@\n", target, action];
			  }];
		 }];
	}
	
	[outputString appendString:@"\n"];
	NSLog(@"AWintrospect: %@", outputString);
}

- (void)logAccesibilityProppertiesForObject:(id)object {
    
    Class objectClass = [object class];
    NSString *className = [NSString stringWithFormat:@"%@", objectClass];
    NSMutableString *outputString = [NSMutableString string];
    
    // warn about accessibility inspector if the element count is zero
    NSUInteger count = [object accessibilityElementCount];
    if (count == 0)
        [outputString appendString:@"\n\n** Warning: Logging accessibility properties requires Accessibility Inspector: Settings.app -> General -> Accessibility\n"];
    
    [outputString appendFormat:@"** %@ Accessibility Properties **\n", className];
    [outputString appendFormat:@"	label: %@\n", [object accessibilityLabel]];
    [outputString appendFormat:@"	hint: %@\n", [object accessibilityHint]];
    [outputString appendFormat:@"	traits: %@\n", [self describeProperty:@"accessibilityTraits" value:[NSNumber numberWithUnsignedLongLong:[object accessibilityTraits]]]];
    [outputString appendFormat:@"	value: %@\n", [object accessibilityValue]];
    [outputString appendFormat:@"	frame: %@\n", NSStringFromCGRect([object accessibilityFrame])];
    [outputString appendString:@"\n"];
    
    NSLog(@"AWIntrospect: %@", outputString);
}

@end

#endif
