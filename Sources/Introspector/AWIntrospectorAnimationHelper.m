//
//  AWIntrospectorAnimationHelper.m
//  AWFoundation
//
//  Created by Steven Roebert on 19-11-2013.
//  Copyright (c) 2013 Steven Roebert. All rights reserved.
//

#if defined(DEBUG)

#import <objc/runtime.h>
#import "AWIntrospectorAnimationHelper.h"

@interface CAAnimation (AWIntrospectorAnimationHelper)
- (CFTimeInterval)AWIntrospectorDuration;
@end

@implementation CAAnimation (AWIntrospectorAnimationHelper)
- (CFTimeInterval)AWIntrospectorDuration {
    CFTimeInterval duration = [self AWIntrospectorDuration];
    if (duration == 0.0) {
        return duration;
    }
    
    duration += [AWIntrospectorAnimationHelper sharedHelper].animationDurationOffset;
    duration *= [AWIntrospectorAnimationHelper sharedHelper].animationDurationFactor;
    if (duration <= 0.0) {
        duration = 0.0001; // Make sure the animation has at least a larger than 0 duration.
    }
    
    return duration;
}
@end

@implementation AWIntrospectorAnimationHelper

+ (instancetype)sharedHelper {
	static id singleton = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		singleton = [(id)[super alloc] init];
	});
	return singleton;
}

#pragma mark -
#pragma mark Initialize

- (id)init {
    if (self = [super init]) {
        _animationDurationFactor = 10.0;
        _animationDurationOffset = 0.0;
    }
    return self;
}

#pragma mark -
#pragma mark Enabled

- (void)setEnabled:(BOOL)enabled {
    if (_enabled == enabled) {
        return;
    }
    
    _enabled = enabled;
    Method method1 = class_getInstanceMethod([CAAnimation class], @selector(duration));
	Method method2 = class_getInstanceMethod([CAAnimation class], @selector(AWIntrospectorDuration));
	method_exchangeImplementations(method1, method2);
}

@end

#endif
