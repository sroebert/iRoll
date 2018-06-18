//
//  AWIntrospectorGadget+Descriptions.h
//  AWFoundation
//
//  Created by Ester on 17/05/13.
//  Copyright (c) 2013 Steven Roebert. All rights reserved.
//

#if defined(DEBUG)

#import "AWIntrospectorGadget.h"

@interface AWIntrospectorGadget (Descriptions)
/**
 Returns a complete and readable description of a given property for a view.
 
 @param propertyName The name of the property.
 @param value The value of the property.
 @return a string containing the description.
 */
- (NSString *)describeProperty:(NSString *)propertyName value:(id)value;

/**
 Returns a string containing the RGBA value of a given color.
 @param color the UIColor
 @return a string with RGBA values of that color.
 */
- (NSString *)describeColor:(UIColor *)color;

@end

#endif
