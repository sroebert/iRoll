//
//  GameScoreModel.m
//  iRoll
//
//  Created by Steven Roebert on 16/02/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//

#import "ScoreModel.h"

@implementation ScoreModel {
    NSArray *_scoreNames;
	NSMutableDictionary *_scores;
}

#pragma mark Class methods

+ (NSArray *)getScoreNames {
	return @[NSLocalizedString(@"SCORES_ACES", @"Aces"),
			NSLocalizedString(@"SCORES_TWOS", @"Twos"),
			NSLocalizedString(@"SCORES_THREES", @"Threes"),
			NSLocalizedString(@"SCORES_FOURS", @"Fours"),
			NSLocalizedString(@"SCORES_FIVES", @"Fives"),
			NSLocalizedString(@"SCORES_SIXES", @"Sixes"),
			NSLocalizedString(@"SCORES_3OFAKIND", @"3 of a Kind"),
			NSLocalizedString(@"SCORES_4OFAKIND", @"4 of a Kind"),
			NSLocalizedString(@"SCORES_FULLHOUSE", @"Full House"),
			NSLocalizedString(@"SCORES_SMALLSTRAIGHT", @"Small Straight"),
			NSLocalizedString(@"SCORES_LARGESTRAIGHT", @"Large Straight"),
			NSLocalizedString(@"SCORES_5OFAKIND", @"5 of a Kind"),
			NSLocalizedString(@"SCORES_CHANCE", @"Chance")];
}

+ (int)getScoreWithName:(NSString *)name forDiceRoll:(DiceRoll)diceRoll {
	int index = [[ScoreModel getScoreNames] indexOfObject:name];
	return [ScoreModel getScoreWithIndex:index forDiceRoll:diceRoll];
}

/**
 * Yahtzee score rules.
 */
+ (int)getScoreWithIndex:(int)index forDiceRoll:(DiceRoll)diceRoll {
	switch (index) {
			// Uppper section
		case 0: case 1: case 2: case 3: case 4:	case 5:
			return [ScoreModel countNumber:index+1 inDiceRoll:diceRoll] * (index + 1);
			
			// Three of a kind
		case 6:
			if ([ScoreModel countMaxEqualsInDiceRoll:diceRoll] < 3) {
				return 0;
			}
			return [ScoreModel countDiceRollTotal:diceRoll];
			// Four of a kind
		case 7:
			if ([ScoreModel countMaxEqualsInDiceRoll:diceRoll] < 4) {
				return 0;
			}
			return [ScoreModel countDiceRollTotal:diceRoll];
			// Full House
		case 8:
			if (![ScoreModel isFullHouseDiceRoll:diceRoll]) {
				return 0;
			}
			return 25;
			// Small Straight
		case 9:
			if (![ScoreModel isSmallStraightDiceRoll:diceRoll]) {
				return 0;
			}
			return 30;
			// Large Straight
		case 10:
			if (![ScoreModel isLargeStraightDiceRoll:diceRoll]) {
				return 0;
			}
			return 40;
			// Yahtzee
		case 11:
			if ([ScoreModel countMaxEqualsInDiceRoll:diceRoll] < 5 || diceRoll.dice[0] == 0) {
				return 0;
			}
			return 50;
			// Chance
		case 12:
			return [ScoreModel countDiceRollTotal:diceRoll];
	}
	return 0;
}

+ (int)countNumber:(int)number inDiceRoll:(DiceRoll)diceRoll {
	int total = 0;
	for (int i = 0; i < DICE_COUNT; i++) {
		if (diceRoll.dice[i] == number) {
			total++;
		}
	}
	return total;
}

+ (int)countDiceRollTotal:(DiceRoll)diceRoll {
	int total = 0;
	for (int i = 0; i < DICE_COUNT; i++) {
		total += diceRoll.dice[i];
	}
	return total;
}

+ (BOOL)number:(int)number inDiceRoll:(DiceRoll)diceRoll {
	for (int i = 0; i < DICE_COUNT; i++) {
		if (diceRoll.dice[i] == number) {
			return YES;
		}
	}
	return NO;
}

+ (int)countMaxEqualsInDiceRoll:(DiceRoll)diceRoll {
	int array[] = { 0, 0, 0, 0, 0, 0 };
	int max = 0;
	for (int i = 0; i < DICE_COUNT; i++) {
		int roll = diceRoll.dice[i] - 1;
		array[roll]++;
		if (array[roll] > max) {
			max = array[roll];
		}
	}
	return max;
}

+ (BOOL)isFullHouseDiceRoll:(DiceRoll)diceRoll {
	int array[] = { 0, 0, 0, 0, 0, 0 };
	for (int i = 0; i < DICE_COUNT; i++) {
		array[diceRoll.dice[i] - 1]++;
	}
	
	int max = 0;
	int min = 6;
	for (int i = 0; i < 6; i++) {
		if (array[i] > max) {
			max = array[i];
		}
		if (array[i] > 0 && array[i] < min) {
			min = array[i];
		}
	}
	return (max == 5 || (max == 3 && min == 2));
}

+ (BOOL)isSmallStraightDiceRoll:(DiceRoll)diceRoll {
	int array[] = { 0, 0, 0, 0, 0, 0 };
	for (int i = 0; i < DICE_COUNT; i++) {
		int roll = diceRoll.dice[i] - 1;
		array[roll]++;
	}
	return ((array[0] >= 1 && array[1] >= 1 && array[2] >= 1 && array[3] >= 1) ||
			(array[1] >= 1 && array[2] >= 1 && array[3] >= 1 && array[4] >= 1) ||
			(array[2] >= 1 && array[3] >= 1 && array[4] >= 1 && array[5] >= 1));
}

+ (BOOL)isLargeStraightDiceRoll:(DiceRoll)diceRoll {
	int array[] = { 0, 0, 0, 0, 0, 0 };
	for (int i = 0; i < DICE_COUNT; i++) {
		int roll = diceRoll.dice[i] - 1;
		array[roll]++;
	}
	return ((array[0] == 1 && array[1] == 1 && array[2] == 1 && array[3] == 1 && array[4] == 1) ||
			(array[1] == 1 && array[2] == 1 && array[3] == 1 && array[4] == 1 && array[5] == 1));
}

#pragma mark Init

- (id)init {
	if ((self = [super init])) {
		_scoreNames = [ScoreModel getScoreNames];
		_scores = [[NSMutableDictionary alloc] initWithCapacity:[_scoreNames count]];
		for	(NSString *scoreName in _scoreNames) {
			_scores[scoreName] = @-1;
		}
	}
	return self;
}

#pragma mark Complete

- (BOOL)isComplete {
	for (NSString *key in _scores) {
		if ([_scores[key] intValue] == -1) {
			return NO;
		}
	}
	return YES;
}

#pragma mark Get/Set Score

- (NSString *)getScoreNameForIndex:(int)index {
	return _scoreNames[index];
}

- (int)getScoreIndexForName:(NSString *)name {
	return [_scoreNames indexOfObject:name];
}

- (int)getScoreWithName:(NSString *)name {
	return [_scores[name] intValue];
}

- (void)setScore:(int)score forName:(NSString *)name {
	_scores[name] = @(score);
}

- (int)getScoreWithIndex:(int)index {
	return [_scores[_scoreNames[index]] intValue];
}

- (void)setScore:(int)score forIndex:(int)index {
	_scores[_scoreNames[index]] = @(score);
}

#pragma mark Total Scores

- (int)bonusScore {
	int total = 0;
	for (int i = 0; i < 6; i++) {
		int score = [self getScoreWithIndex:i];
		if (score > -1) {
			total += score;
		}
	}
	return ((total >= 63) ? 35 : 0);
}

- (int)upperTotalScore {
	int total = 0;
	for (int i = 0; i < 6; i++) {
		int score = [self getScoreWithIndex:i];
		if (score > -1) {
			total += score;
		}
	}
	return total + ((total >= 63) ? 35 : 0);
}

- (int)lowerTotalScore {
	int total = 0;
	for (int i = 6; i < 13; i++) {
		int score = [self getScoreWithIndex:i];
		if (score > -1) {
			total += score;
		}
	}
	return total;
}

- (int)totalScore {
	return self.upperTotalScore + self.lowerTotalScore;
}

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:_scores forKey:@"scores"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super init])) {
		_scoreNames = [ScoreModel getScoreNames];
		_scores = [aDecoder decodeObjectForKey:@"scores"];
	}
	return self;
}

@end
