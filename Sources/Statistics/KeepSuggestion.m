//
//  KeepSuggestion.m
//  iRoll
//
//  Created by Steven Roebert on 18/03/2010.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "KeepSuggestion.h"


@implementation KeepSuggestion

- (id)initWithState:(WidgetState)state andPotential:(float)value {
	if ((self = [super init])) {
		_keepState = state;
		_potential = [[NSNumber alloc] initWithFloat:value];
	}
	return self;
}

- (NSComparisonResult)compareSuggestion:(KeepSuggestion *)suggestion {
	return [suggestion.potential compare:_potential];
}

@end
