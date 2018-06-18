//
//  GameModel.m
//  iRoll
//
//  Created by Steven Roebert on 16/02/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//

#import "GameModel.h"


@implementation GameModel {
	NSMutableArray *_scores;
	NSMutableArray *_names;
}

#pragma mark Init

- (id)init {
	return [self initWithPlayers:1];
}

- (id)initWithPlayers:(int)players {
	if ((self = [super init])) {
		_nPlayers = players;
		_currentPlayer = 0;
		_currentRoll = 0;
		
		_scores = [[NSMutableArray alloc] initWithCapacity:players];
		_names = [[NSMutableArray alloc] initWithCapacity:players];
		for (int i = 0; i < players; i++) {
			ScoreModel *scoreModel = [[ScoreModel alloc] init];
			[_scores addObject:scoreModel];
			
			[_names addObject:[NSString stringWithFormat:@"%@ %d", NSLocalizedString(@"GAME_PLAYER", @"Player"), i + 1]];
		}
		
		for (int i = 0; i < DICE_COUNT; i++) {
			[self setDieValue:i value:0];
		}
	}
	return self;
}

#pragma mark Get/Set

- (int)getDieValue:(int)index {
	return _diceRoll.dice[index];
}

- (void)setDieValue:(int)index value:(int)value {
	_diceRoll.dice[index] = value;
}

- (ScoreModel *)getPlayerScore:(int)player {
	if (player == -1) {
		return _scores[_currentPlayer];
	}
	return _scores[player];
}

- (void)setScore:(ScoreModel *)score forPlayer:(int)player {
	if (player == -1) {
		_scores[_currentPlayer] = score;
	}
	_scores[player] = score;
}

- (NSString *)getPlayerName:(int)player {
	if (player == -1) {
		player = _currentPlayer;
	}
	return _names[player];
}

- (void)setName:(NSString *)name forPlayer:(int)player {
	if (player == -1) {
		player = _currentPlayer;
	}
	if (name == nil || [name length] == 0) {
		name = [NSString stringWithFormat:@"%@ %d", NSLocalizedString(@"GAME_PLAYER", @"Player"), player + 1];
	}
	_names[player] = name;
}

#pragma mark Utils

- (BOOL)isEndOfGame {
	// If all scores are used, we have reached the end of the game
	for (ScoreModel *scoreModel in _scores) {
		if (!scoreModel.isComplete) {
			return NO;
		}
	}
	return YES;
}

#pragma mark NSCoding

/**
 * NSCoding implementation, used for saving and loading the game to and from disk.
 */

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeInt:_nPlayers forKey:@"nPlayers"];
	[aCoder encodeInt:_currentPlayer forKey:@"currentPlayer"];
	[aCoder encodeInt:_currentRoll forKey:@"currentRoll"];
	
	for (int i = 0; i < DICE_COUNT; i++) {
		[aCoder encodeInt:_diceRoll.dice[i] forKey:
			[NSString stringWithFormat:@"diceRoll.%d", i + 1]];
	}
	
	[aCoder encodeObject:_scores forKey:@"scores"];
	[aCoder encodeObject:_names forKey:@"names"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super init])) {
		_nPlayers = [aDecoder decodeIntForKey:@"nPlayers"];
		_currentPlayer = [aDecoder decodeIntForKey:@"currentPlayer"];
		_currentRoll = [aDecoder decodeIntForKey:@"currentRoll"];
		
		for (int i = 0; i < DICE_COUNT; i++) {
			_diceRoll.dice[i] = [aDecoder decodeIntForKey:
				[NSString stringWithFormat:@"diceRoll.%d", i + 1]];
		}
		
		_scores = [aDecoder decodeObjectForKey:@"scores"];
		_names = [aDecoder decodeObjectForKey:@"names"];
	}
	return self;
}

@end
