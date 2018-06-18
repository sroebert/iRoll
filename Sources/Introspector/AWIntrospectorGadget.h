//
//  AWIntrospectorGadget.h
//  AWFoundation
//
//  Created by Steven Roebert on 19-11-2013.
//  Copyright (c) 2013 Steven Roebert. All rights reserved.
//

#if defined(DEBUG)

@interface AWIntrospectorGadget : NSObject

+ (AWIntrospectorGadget *)sharedIntrospector;

@property (nonatomic, assign, getter = isEnabled) BOOL enabled;

@end

#endif
