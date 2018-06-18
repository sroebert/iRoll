//
//  GameUIState.m
//  iRoll
//
//  Created by Steven Roebert on 26/02/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//

#import "GameUIState.h"


@implementation GameUIState {
    NSMutableArray *_scoreViewModes;
	NSMutableArray *_dieButtonStates;
}

#pragma mark Init

- (id)init {
	if ((self = [super init])) {
		_scoreViewModes = [[NSMutableArray alloc] init];
		_dieButtonStates = [[NSMutableArray alloc] init];
	}
	return self;
}

#pragma mark Get/Set

- (ScoreViewMode)getViewModeForPlayer:(int)player {
	while (player >= [_scoreViewModes count]) {
		[_scoreViewModes addObject:@((int)ScoreViewModeDefault)];
	}
	return (ScoreViewMode)[_scoreViewModes[player] intValue];
}
- (void)setViewMode:(ScoreViewMode)mode forPlayer:(int)player {
	while (player >= [_scoreViewModes count]) {
		[_scoreViewModes addObject:@((int)ScoreViewModeDefault)];
	}
	_scoreViewModes[player] = @((int)mode);
}

- (BOOL)getSelectedStateForDie:(int)die {
	while (die >= [_dieButtonStates count]) {
		[_dieButtonStates addObject:@NO];
	}
	return [_dieButtonStates[die] boolValue];
}
- (void)setSelectedState:(BOOL)state forDie:(int)die {
	while (die >= [_dieButtonStates count]) {
		[_dieButtonStates addObject:@NO];
	}
	_dieButtonStates[die] = @(state);
}

#pragma mark NSCoding

/**
 * NSCoding implementation, used for saving and loading the game to and from disk.
 */

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:_scoreViewModes forKey:@"scoreViewModes"];
	[aCoder encodeObject:_dieButtonStates forKey:@"dieButtonStates"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super init])) {
		_scoreViewModes = [aDecoder decodeObjectForKey:@"scoreViewModes"];
		_dieButtonStates = [aDecoder decodeObjectForKey:@"dieButtonStates"];
	}
	return self;
}

@end
