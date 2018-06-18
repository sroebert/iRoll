//
//  AWIntrospectorViewParameters
//  AWFoundation
//
//  Created by Ester on 14/05/13.
//  Copyright (c) 2013 Steven Roebert. All rights reserved.
//

#if defined(DEBUG)

/**
 This class is used as a container for the original values of the propperties of a view.
 The properties saved are: original frame, alpha, hidden value and background color.
 */
@interface AWIntrospectorViewParameters : NSObject

- (id)initWithView:(UIView *)view;

@property (nonatomic, weak, readonly) UIView *view;

@property (nonatomic, readonly) CGRect frame;
@property (nonatomic, readonly) CGFloat alpha;
@property (nonatomic, readonly) BOOL hidden;
@property (nonatomic, readonly) UIColor *backgroundColor;

@end

#endif
