//
//  KeepSuggestion.h
//  iRoll
//
//  Created by Steven Roebert on 18/03/2010.
//  Copyright 2010 Apple Inc. All rights reserved.
//
//	Class for storing the a keep state suggestion with its potential, it contains
//	a sort function to sort based on potential.
//

#import "Widget.h"

@interface KeepSuggestion : NSObject

@property (nonatomic, readonly) NSNumber *potential;
@property (nonatomic, readonly) WidgetState keepState;

- (id)initWithState:(WidgetState)state andPotential:(float)value;
- (NSComparisonResult)compareSuggestion:(KeepSuggestion *)suggestion;

@end
