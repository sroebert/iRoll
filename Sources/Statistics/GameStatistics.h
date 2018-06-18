//
//  GameStatistics.h
//  iRoll
//
//  Created by Steven Roebert on 18/03/2010.
//  Copyright 2010 Apple Inc. All rights reserved.
//
//	Class used in iRoll to get suggestions into the game. It uses the same classes used for
//	calculating the complete state graph.
//

#import "DiceRoll.h"
#import "ScoreModel.h"

#define N_WIDGETS 524288

@interface GameStatistics : NSObject

@property (nonatomic, readonly) NSArray *keepSuggestions, *scoreSuggestions;

- (void)calculateStrategyForScoreModel:(ScoreModel *)scoreModel;
- (void)calculateKeepSuggestionsForDiceRoll:(DiceRoll)roll withCurrent:(int)currentRoll;
- (void)calculateScoreSuggestionsForDiceRoll:(DiceRoll)roll;

@end
