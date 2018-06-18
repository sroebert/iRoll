//
//  GameStatistics.m
//  iRoll
//
//  Created by Steven Roebert on 18/03/2010.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "GameStatistics.h"
#import "Widget.h"
#import "KeepSuggestion.h"
#import "ScoreSuggestion.h"

@implementation GameStatistics {
    Widget *_widget;
	float _potentials[N_WIDGETS];
	
	NSMutableArray *_keepSuggestions;
	NSMutableArray *_scoreSuggestions;
}

#pragma mark Init

- (id)init {
	if ((self = [super init])) {
		// Load widgetdata from resource file
		_widget = [[Widget alloc] initFromHash:0 withDataFile:
			[[NSBundle mainBundle] pathForResource:@"widgetdata" ofType:@"bin"]];
		
		// Load widget potentials from resource file
		NSData *data = [[NSData alloc] initWithContentsOfFile:
			[[NSBundle mainBundle] pathForResource:@"potentials" ofType:@"bin"]];
		[data getBytes:_potentials length:sizeof(float)*N_WIDGETS];
		
		[_widget calculatePotential:_potentials];
	}
	return self;
}

#pragma mark Statistics

/**
 * Calculate all potentials for the states in a widget, using a scoremodel to indicate what
 * widget will be used.
 */
- (void)calculateStrategyForScoreModel:(ScoreModel *)scoreModel {
	
	// First calculate the widget hash
	int hash = scoreModel.upperTotalScore;
	if (hash > 63) {
		hash = 63;
	}
	
	for (int i = 0; i < SCORE_TYPE_COUNT; i++) {
		if ([scoreModel getScoreWithIndex:i] > -1) {
			hash |= ((1 << i) << N_SCORE_BYTES);
		}
	}
	
	// Set the hash and calculate potentials (if not already done so)
	if (_widget.hash != hash) {
		[_widget setHash:hash];
		[_widget calculatePotential:_potentials];
	}
}

/**
 * Get all possible keep suggestions and sort them based on potentials, given the current dice roll.
 */
- (void)calculateKeepSuggestionsForDiceRoll:(DiceRoll)roll withCurrent:(int)currentRoll {
	
	// Get the states group for the current dice roll (see paper for detailed explanation)
	int group = (currentRoll * 2) + 1;
	if (group != 3 && group != 5) {
		return;
	}
	
	// Get roll state with hash and all edges from this roll state to possible keep states
	WidgetState rollState = [Widget stateForDiceRoll:roll];
	int rollHash = [Widget hashForState:rollState];
	int rollIndex;
	[Widget sortedArraySearch:_widget.widgetData.data->rollStates 
					withCount:N_ROLL_STATES forValue:rollHash atIndex:&rollIndex];
	
	int nPossibleKeeps = _widget.widgetData.data->roll2KeepCounts[rollIndex];
	int *possibleKeeps = _widget.widgetData.data->roll2KeepEdges[rollIndex];
	_keepSuggestions = [[NSMutableArray alloc] initWithCapacity:nPossibleKeeps];
	
	@autoreleasepool {
	
	// For each edge to a keep state, add the keep state and potential to the list of suggestions
		for (int i = 0; i < nPossibleKeeps; i++) {
			int keepIndex = possibleKeeps[i];
			WidgetState keepState = [Widget stateForHash:_widget.widgetData.data->keepStates[keepIndex]];
			float potential = [_widget getGroupPotential:group forIndex:keepIndex];
			
			KeepSuggestion *suggestion = [[KeepSuggestion alloc]
				initWithState:keepState andPotential:potential];
			[_keepSuggestions addObject:suggestion];
		}
	
	}
	
	// Sort suggestions based on potentials
	[_keepSuggestions sortUsingSelector:@selector(compareSuggestion:)];
}

/**
 * Get all possible scores for a dice roll and sort based on potential.
 */
- (void)calculateScoreSuggestionsForDiceRoll:(DiceRoll)roll {
	_scoreSuggestions = [[NSMutableArray alloc] initWithCapacity:SCORE_TYPE_COUNT];
	
	// Get the category hash, indicating which categories have been used
	int categoryHash = (_widget.hash >> N_SCORE_BYTES);
	
	// Go through all score categories
	for (int i = 0; i < SCORE_TYPE_COUNT; i++) {
		
		// If it has been used, simply add a potential of -1, 
		// making sure it is sorted to the bottom of the list
		if (((categoryHash >> i) & 1) == 1) {
			ScoreSuggestion *suggestion = [[ScoreSuggestion alloc]
				initWithScoreIndex:i andPotential:-1 andScore:-1];
			[_scoreSuggestions addObject:suggestion];
		}
		// Otherwise calculate the potential for the score and add it to the list
		else {
			int rollScore = [ScoreModel getScoreWithIndex:i forDiceRoll:roll];
			int nextHash = [Widget nextWidgetForScore:rollScore inCategory:i withCurrentHash:_widget.hash];
			float potential = round((_potentials[nextHash] + rollScore) * 100) / 100;
			
			ScoreSuggestion *suggestion = [[ScoreSuggestion alloc]
				initWithScoreIndex:i andPotential:potential andScore:rollScore];
			[_scoreSuggestions addObject:suggestion];
		}
	}
	
	// Sort suggestions based on potentials
	[_scoreSuggestions sortUsingSelector:@selector(compareSuggestion:)];
}

#pragma mark Properties

- (NSArray *)keepSuggestions
{
    return _keepSuggestions;
}

- (NSArray *)scoreSuggestions
{
    return _scoreSuggestions;
}

@end
