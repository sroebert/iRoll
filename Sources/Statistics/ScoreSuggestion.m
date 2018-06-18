//
//  ScoreSuggestion.m
//  iRoll
//
//  Created by Steven Roebert on 18/03/2010.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ScoreSuggestion.h"


@implementation ScoreSuggestion

- (id)initWithScoreIndex:(int)index andPotential:(float)potentialValue andScore:(int)scoreValue {
	if ((self = [super init])) {
		_scoreIndex = [[NSNumber alloc] initWithInt:index];
		_score = [[NSNumber alloc] initWithInt:scoreValue];
		_potential = [[NSNumber alloc] initWithFloat:potentialValue];
	}
	return self;
}

- (NSComparisonResult)compareSuggestion:(ScoreSuggestion *)suggestion {
	NSComparisonResult result = [suggestion.potential compare:_potential];
	if (result == NSOrderedSame) {
		result = [suggestion.score compare:_score];
		if (result == NSOrderedSame) {
			return [_scoreIndex compare:suggestion.scoreIndex];
		}
	}
	return result;
}

@end
