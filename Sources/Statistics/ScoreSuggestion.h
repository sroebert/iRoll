//
//  ScoreSuggestion.h
//  iRoll
//
//  Created by Steven Roebert on 18/03/2010.
//  Copyright 2010 Apple Inc. All rights reserved.
//
//	Class for storing the a score suggestion with its potential, it contains
//	a sort function to sort based on potential.
//

@interface ScoreSuggestion : NSObject

@property (nonatomic, readonly) NSNumber *potential, *score, *scoreIndex;

- (id)initWithScoreIndex:(int)index andPotential:(float)potentialValue andScore:(int)scoreValue;
- (NSComparisonResult)compareSuggestion:(ScoreSuggestion *)suggestion;

@end
