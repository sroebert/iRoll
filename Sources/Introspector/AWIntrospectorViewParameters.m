//
//  AWIntrospectorViewParameters
//  AWFoundation
//
//  Created by Ester on 14/05/13.
//  Copyright (c) 2013 Steven Roebert. All rights reserved.
//

#if defined(DEBUG)

#import "AWIntrospectorViewParameters.h"

@implementation AWIntrospectorViewParameters

- (id)initWithView:(UIView *)view {
    if ((self = [super init])) {
        _view = view;
        _frame = view.frame;
        _alpha = view.alpha;
        _hidden = view.hidden;
        _backgroundColor = view.backgroundColor;
    }
    return self;
}

@end

#endif
