//
//  GameScoreModel.h
//  iRoll
//
//  Created by Steven Roebert on 16/02/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//
//	This class contains all the scores for a player. It also contains methods for calculating
//	a score for a category with a specific dice roll.
//

#import "DiceRoll.h"

#define SCORE_TYPE_COUNT 13

@interface ScoreModel : NSObject <NSCoding>

@property (readonly) BOOL isComplete;
@property (readonly) int bonusScore, upperTotalScore, lowerTotalScore, totalScore;

+ (NSArray *)getScoreNames;
+ (int)getScoreWithName:(NSString *)name forDiceRoll:(DiceRoll)diceRoll;
+ (int)getScoreWithIndex:(int)index forDiceRoll:(DiceRoll)diceRoll;

+ (int)countNumber:(int)number inDiceRoll:(DiceRoll)diceRoll;
+ (int)countDiceRollTotal:(DiceRoll)diceRoll;
+ (BOOL)number:(int)number inDiceRoll:(DiceRoll)diceRoll;
+ (int)countMaxEqualsInDiceRoll:(DiceRoll)diceRoll;

+ (BOOL)isFullHouseDiceRoll:(DiceRoll)diceRoll;
+ (BOOL)isSmallStraightDiceRoll:(DiceRoll)diceRoll;
+ (BOOL)isLargeStraightDiceRoll:(DiceRoll)diceRoll;

- (NSString *)getScoreNameForIndex:(int)index;
- (int)getScoreIndexForName:(NSString *)name;

- (int)getScoreWithName:(NSString *)name;
- (void)setScore:(int)score forName:(NSString *)name;

- (int)getScoreWithIndex:(int)index;
- (void)setScore:(int)score forIndex:(int)index;

@end
