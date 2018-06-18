//
//  AWIntrospectorGadget+Logs.h
//  AWFoundation
//
//  Created by Ester on 21/05/13.
//  Copyright (c) 2013 Steven Roebert. All rights reserved.
//
#if defined(DEBUG)

#import "AWIntrospectorGadget.h"

@interface AWIntrospectorGadget (Logs)

/**
 Logs all properties for a given view into a readable string.
 It also logs target and actions in case the view has it.

 @param view The view.
 */
- (void)logProppertiesForView:(UIView *)view;

/**
 Logs the accesibility properties for a given object (usually a view).
 
 @param object The object to check for the accesibility properties.
 */
- (void)logAccesibilityProppertiesForObject:(id)object;

@end

#endif
