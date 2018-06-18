//
//  AWIntrospectorAnimationHelper.h
//  AWFoundation
//
//  Created by Steven Roebert on 19-11-2013.
//  Copyright (c) 2013 Steven Roebert. All rights reserved.
//

#if defined(DEBUG)

/**
 Helper class to change animation duration dinamically.
 
 The duration can be changed in two ways: 
 - with an offset that will be added to the total duration of the original animation duration
 - with a factor that will be multiplied to the original duration.
 
 By default, animationDurationFactor is 10.0 (same as the `Toggle Slow Animations` function of the simulator).
 */
@interface AWIntrospectorAnimationHelper : NSObject

+ (AWIntrospectorAnimationHelper *)sharedHelper;

@property (nonatomic, assign, getter = isEnabled) BOOL enabled;

@property (nonatomic, assign) NSTimeInterval animationDurationOffset;
@property (nonatomic, assign) double animationDurationFactor;

@end

#endif
