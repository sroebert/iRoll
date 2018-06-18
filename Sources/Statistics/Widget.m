//
//  State.m
//  iRoll
//
//  Created by Steven Roebert on 02/03/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//

#import "Widget.h"
#import "WidgetValidator.h"
#import "ScoreModel.h"

@implementation Widget {
    BOOL _filledCategories[SCORE_TYPE_COUNT];
	
	// Hash value is used to identify the widget, it consists of a 13 bit number, indicating
	// which categories have been used, together with a 6 bit number indicating the score for the
	// upper section.
	int _hashValue;
	
	float _group2Potentials[N_ROLL_STATES],
        _group3Potentials[N_KEEP_STATES],
        _group4Potentials[N_ROLL_STATES],
        _group5Potentials[N_KEEP_STATES],
        _group6Potentials[N_ROLL_STATES];
}

static WidgetValidator *_widgetValidator = nil;

#pragma mark Init/Hash

- (id)init {
	return [self initFromHash:0];
}

- (id)initFromHash:(int)hash {
	return [self initFromHash:hash withDataFile:nil];
}

- (id)initWithDataFile:(NSString *)file {
	return [self initFromHash:0 withDataFile:file];
}

- (id)initFromHash:(int)hash withDataFile:(NSString *)file {
	if ((self = [super init])) {
		[self setHash:hash];
		
		_widgetData = [[WidgetData alloc] init];
		if (![_widgetData loadFromFile:file]) {
			[self _initGroupsAndEdges];
		}
	}
	return self;
}

- (NSUInteger)hash {
	if (_hashValue == -1) {
		int categoryHash = 0;
		for (int i = 0; i < SCORE_TYPE_COUNT; i++) {
			if (_filledCategories[i]) {
				categoryHash += (1 << i);
			}
		}
		_hashValue = _totalUpperScore + (categoryHash << N_SCORE_BYTES);
	}
	return _hashValue;
}

- (void)setHash:(int)hash {
	_hashValue = hash;
	_potential = -1;
	int categoryHash = (hash >> N_SCORE_BYTES);
	for (int i = 0; i < SCORE_TYPE_COUNT; i++) {
		_filledCategories[i] = (((categoryHash >> i) & 1) == 1);
	}
	_totalUpperScore = (hash & 63);
}

- (void)saveWidgetDataToFile:(NSString *)file {
	[_widgetData saveToFile:file];
}

#pragma mark Validation

+ (BOOL)isValidHash:(int)hash {
	// Use a widget validator class to verify if a hash is a hash for a valid widget
	if (_widgetValidator == nil) {
		_widgetValidator = [[WidgetValidator alloc] init];
	}
	return [_widgetValidator validateWidgetHash:hash];
}

- (BOOL)isValid {
	// Use a widget validator class to verify if the current widget is a valid widget
	if (_widgetValidator == nil) {
		_widgetValidator = [[WidgetValidator alloc] init];
	}
	return [_widgetValidator validateWidget:self];
}

- (BOOL)getCategoryFilledForIndex:(int)index {
	return _filledCategories[index];
}

#pragma mark States

/**
 * Getting a widget roll state for a dice roll
 */
+ (WidgetState)stateForDiceRoll:(DiceRoll)roll {
	WidgetState state;
	for (int i = 0; i < MAX_DIE_VALUE; i++) {
		state.values[i] = 0;
	}
	for (int i = 0; i < DICE_COUNT; i++) {
		state.values[roll.dice[i]-1]++;
	}
	return state;
}

/**
 * Getting a dice roll for a widget roll state
 */
+ (DiceRoll)diceRollForState:(WidgetState)state {
	DiceRoll roll;
	int stateIndex = 0;
	for (int i = 0; i < DICE_COUNT; i++) {
		while (stateIndex < MAX_DIE_VALUE && state.values[stateIndex] == 0) {
			stateIndex++;
		}
		roll.dice[i] = stateIndex + 1;
		state.values[stateIndex]--;
	}
	return roll;
}

/**
 * Get the dice roll for a widget roll state hash
 */
+ (DiceRoll)diceRollForHash:(int)hash {
	DiceRoll roll;
	float value = (float)hash;
	int currDie = 0;
	for (int i = 0; i < MAX_DIE_VALUE; i++) {
		int quotient = floor(value / MAX_DIE_VALUE);
		
		int currValue = (int)value - (quotient * MAX_DIE_VALUE);
		while (currValue > 0) {
			roll.dice[currDie] = i + 1;
			currValue--;
			currDie++;
		}
		
		value = quotient;
	}
	return roll;
}


/**
 * Getting the hash for a widget roll/keep state
 */
+ (int)hashForState:(WidgetState)state {
	int hash = 0;
	for (int i = 0; i < MAX_DIE_VALUE; i++) {
		hash += state.values[i] * pow(MAX_DIE_VALUE, i);
	}
	return hash;
}

/**
 * Getting the widget roll/keep state for a hash
 */
+ (WidgetState)stateForHash:(int)hash {
	WidgetState state;
	float value = (float)hash;
	for (int i = 0; i < MAX_DIE_VALUE; i++) {
		int quotient = floor(value / MAX_DIE_VALUE);
		state.values[i] = (int)value - (quotient * MAX_DIE_VALUE);
		value = quotient;
	}
	return state;
}

#pragma mark Potentials

/**
 * Utility method for searching a sorted array for a specific value.
 */
+ (BOOL)sortedArraySearch:(int *)array withCount:(int)count 
				 forValue:(int)value atIndex:(int *)index
{
	int low = 0;
	int high = count;
	
	while (low < high) {
		int mid = low + ((high - low) / 2);
		if (array[mid] < value) {
			low = mid + 1;
		}
		else {
			high = mid;
		}
	}
	
	if (low < count) {
		if (array[low] == value) {
			*index = low;
			return YES;
		}
		else if (array[low] < value) {
			*index = low + 1;
		}
		else {
			*index = low;
		}
		return NO;
	}
	
	*index = count;
	return NO;
}

/**
 * Method for inserting a value in a sorted array. If the value already exists, nothing is done.
 * Return true if the value was inserted, false if it was already found in the array. The array
 * must be large enough to have one element added to it.
 */
+ (BOOL)_insertSetValue:(int)value inArray:(int *)array withCount:(int)count atIndex:(int *)index {
	int insertIndex;
	if ([Widget sortedArraySearch:array withCount:count forValue:value atIndex:&insertIndex]) {
		if (index != nil) {
			*index = insertIndex;
		}
		return NO;
	}
	
	for (int i = count; i > insertIndex; i--) {
		array[i] = array[i-1];
	}
	array[insertIndex] = value;
	if (index != nil) {
		*index = insertIndex;
	}
	return YES;
}

/**
 * Utility method for calculating (n over k) combinations
 */
+ (int)_calculateCombinations:(int)k from:(int)n {
	if (k > n) {
        return 0;
	}
	
    if (k > n / 2) {
        k = n - k;
	}
	
    float accum = 1;
    for (int i = 1; i <= k; i++) {
		accum = (accum * (n-k+i)) / i;
	}
	
    return (int)(accum + 0.5);
}

/**
 * Calculate the probability of throwing a number of dice with the values given by a widgetstate.
 */
+ (float)_probabilityForState:(WidgetState)state withNumberOfDice:(int)diceNumber {
	int combinations = 1;
	int counter = diceNumber;
	
	// Simply go through all specific die face values and calculate the number of combinations.
	for (int i = 0; i < MAX_DIE_VALUE; i++) {
		if (state.values[i] > 0) {
			combinations *= [Widget _calculateCombinations:state.values[i] from:counter];
			counter -= state.values[i];
		}
	}
	
	// The final probability is the number of combinations divided by the 
	// number of total possibilities
	return combinations / (float)pow(MAX_DIE_VALUE, diceNumber);
}

/**
 * Init method which calculates all possible keep and roll states in a widget. Also calculates
 * all the edges between keep and roll states.
 */
- (void)_initGroupsAndEdges {
	int rollCount = 0;
	int keepCount = 0;
	
	DiceRoll diceRoll;
	int diceTotal = 0;
	diceRoll.dice[0] = 0;
	for (int i = 1; i < DICE_COUNT; i++) {
		diceRoll.dice[i] = 1;
		diceTotal++;
	}
	// Go through all roll states
	while (diceTotal < DICE_COUNT * MAX_DIE_VALUE)
	{
		for (int i = 0; i < DICE_COUNT; i++) {
			diceRoll.dice[i]++;
			diceTotal++;
			
			if (diceRoll.dice[i] <= MAX_DIE_VALUE) {
				break;
			}
			
			diceRoll.dice[i] = 1;
			diceTotal -= MAX_DIE_VALUE;
		}
		
		// Get the roll state and hash for the current roll
		WidgetState rollState = [Widget stateForDiceRoll:diceRoll];
		int rollHash = [Widget hashForState:rollState];
		int rollIndex;
		
		// Add the hash to all the roll states
		if ([Widget _insertSetValue:rollHash inArray:_widgetData.data->rollStates
						  withCount:rollCount atIndex:&rollIndex]) {
			// If it was not already in the array add one to the counter
			rollCount++;
		}
		
		WidgetState keepState;
		int keepTotal = -1;
		keepState.values[0] = -1;
		for (int i = 1; i < 6; i++) {
			keepState.values[i] = 0;
		}
		// Now go through all keep states using the current roll state
		while (keepTotal < DICE_COUNT)
		{
			for (int i = 0; i < MAX_DIE_VALUE; i++) {
				keepState.values[i]++;
				keepTotal++;
				if (keepState.values[i] <= rollState.values[i]) {
					break;
				}
				keepState.values[i] = 0;
				keepTotal -= rollState.values[i] + 1;
			}
			
			// Get the hash for the keep state
			int keepHash = [Widget hashForState:keepState];
			int keepIndex;
			
			// Add the hash to all the keep states
			if ([Widget _insertSetValue:keepHash inArray:_widgetData.data->keepStates
							  withCount:keepCount atIndex:&keepIndex]) {
				// If it was not already in the array add one to the counter
				keepCount++;
			}
		}
	}
	
	// Init the keep2roll edge counts to 0
	for (int i = 0; i < N_KEEP_STATES; i++) {
		_widgetData.data->keep2RollCounts[i] = 0;
	}
	
	// Go through all roll states
	for (int i = 0; i < N_ROLL_STATES; i++) {
		WidgetState rollState = [Widget stateForHash:_widgetData.data->rollStates[i]];
		
		// Init the roll2keep edge count to 0
		_widgetData.data->roll2KeepCounts[i] = 0;
		
		// Go through all keep states
		for (int j = 0; j < N_KEEP_STATES; j++) {
			WidgetState keepState = [Widget stateForHash:_widgetData.data->keepStates[j]];
			
			// Check if the keep state is possible from the current roll state
			BOOL possible = YES;
			for (int k = 0; k < MAX_DIE_VALUE; k++) {
				// If you keep more dice of a specific value than there exist in
				// the roll state, obviously this is not possible
				if (rollState.values[k] < keepState.values[k]) {
					possible = FALSE;
					break;
				}
			}
			
			// If it is possible, add an edge from the roll to keep state and visa versa
			if (possible) {
				_widgetData.data->roll2KeepEdges[i][_widgetData.data->roll2KeepCounts[i]++] = j;
				_widgetData.data->keep2RollEdges[j][_widgetData.data->keep2RollCounts[j]++] = i;
			}
		}
	}
}

/**
 * Method to check if this widget is a final widget, where all categories have been used.
 */
- (BOOL)_isFinalState {
	return ((self.hash >> N_SCORE_BYTES) == pow(2, SCORE_TYPE_COUNT) - 1);
}

/**
 * Calculate the potentials for the group 6 states in a widget.
 */
- (BOOL)_calculateGroup6Potentials:(float *)potentials {
	// Go through all roll states
	for (int i = 0; i < N_ROLL_STATES; i++) {
		float bestPotential = -1;
		DiceRoll roll = [Widget diceRollForHash:_widgetData.data->rollStates[i]];
		
		// Go through all categories
		for (int j = 0; j < 13; j++) {
			// If already used, skip it
			if (_filledCategories[j]) {
				continue;
			}
			
			// Calculate the score for this category used the current roll
			int categoryScore = [ScoreModel getScoreWithIndex:j forDiceRoll:roll];
			
			// Get the hash for the widget you will end up in, after using this category
			int nextWidgetHash = [Widget nextWidgetForScore:categoryScore inCategory:j
											withCurrentHash:self.hash];
			
			// If the potential for the next widget has not been calculated, return NO, 
			// indicating that the potentials can not successfully be calculated
			if (potentials[nextWidgetHash] == -1) {
				return NO;
			}
			
			// Calculate the potential for using this category, if it is higher
			// than the current maximum, make it the new maximum
			float totalPotential = categoryScore + potentials[nextWidgetHash];
			if (totalPotential > bestPotential) {
				bestPotential = totalPotential;
			}
		}
		
		// Save maximum potential as the potential for this roll state in group 6
		_group6Potentials[i] = bestPotential;
	}
	return YES;
}

/**
 * Calculate the potentials for the keep states groups (3 and 5) in a widget.
 */
- (void)_calculateKeepGroupPotentials:(float *)keepPotentials 
			  withRollGroupPotentials:(float *)rollPotentials
{
	// Go through all keep states
	for (int i = 0; i < N_KEEP_STATES; i++) {
		float keepPotential = 0;
		WidgetState keepState = [Widget stateForHash:_widgetData.data->keepStates[i]];
		
		// Go through all edges to roll states
		for (int j = 0; j < _widgetData.data->keep2RollCounts[i]; j++) {
			int rollIndex = _widgetData.data->keep2RollEdges[i][j];
			WidgetState rollState = [Widget stateForHash:_widgetData.data->rollStates[rollIndex]];
			
			// Check which dice were rolled to get into the roll state, so removing
			// the dice which were kept
			WidgetState diffState;
			int dieCount = 0;
			for (int k = 0; k < MAX_DIE_VALUE; k++) {
				diffState.values[k] = rollState.values[k] - keepState.values[k];
				dieCount += diffState.values[k];
			}
			
			// Calculate the probability for rolling the dice which have not been kept
			float probability = [Widget _probabilityForState:diffState withNumberOfDice:dieCount];
			
			// Add the probability times the potential of the roll state to the keep 
			// state potential (weighted sum)
			float rollPotential = rollPotentials[rollIndex];
			keepPotential += probability * rollPotential;
		}
		
		// Store the weighted potential
		keepPotentials[i] = keepPotential;
	}
}

/**
 * Calculate the potentials for the roll states groups (2 and 4, not 6) in a widget.
 */
- (void)_calculateRollGroupPotentials:(float *)rollPotentials 
			  withKeepGroupPotentials:(float *)keepPotentials
{
	// Go through all roll states
	for (int i = 0; i < N_ROLL_STATES; i++) {
		float maxPotential = 0;
		
		// Go through all edges to keep states and simply take the maximum potential (as the
		// user can simply choose which dice to keep)
		for (int j = 0; j < _widgetData.data->roll2KeepCounts[i]; j++) {
			int keepIndex = _widgetData.data->roll2KeepEdges[i][j];
			float keepPotential = keepPotentials[keepIndex];
			if (keepPotential > maxPotential) {
				maxPotential = keepPotential;
			}
		}
		
		// Store the maximum potential
		rollPotentials[i] = maxPotential;
	}
}

/**
 * Calculate the potential for the state in group 1 of the widget, which is essentially the
 * widget potential.
 */
- (void)_calculateWidgetPotential {
	float widgetPotential = 0;
	
	// Go through all roll states
	for (int i = 0; i < N_ROLL_STATES; i++) {
		float rollPotential = _group2Potentials[i];
		WidgetState rollState = [Widget stateForHash:_widgetData.data->rollStates[i]];
		
		// Calculate the probability for rolling this roll
		float probability = [Widget _probabilityForState:rollState withNumberOfDice:DICE_COUNT];
		
		// Add the weighted potential to the total
		widgetPotential += probability * rollPotential;
	}
	
	// Store the widget potential
	_potential = widgetPotential;
}

/**
 * Calculate all potentials for each state inside this widget.
 */
- (BOOL)calculatePotential:(float *)potentials {
	
	// If this widget is a final widget, the widget potential is simply 0 or 35, depending
	// on whether a bonus was received
	if ([self _isFinalState]) {
		_potential = (self.totalUpperScore >= 63 ? 35 : 0);
		return YES;
	}
	
	// Try to calculate the group 6 potentials
	if (![self _calculateGroup6Potentials:potentials]) {
		// If it could not be calculated, because the potential for the next widget has not yet
		// been calculated, return NO
		return NO;
	}
	
	// Otherwise continue calculating the potentials for groups 5, 4, 3, 2 and 1
	[self _calculateKeepGroupPotentials:_group5Potentials withRollGroupPotentials:_group6Potentials];
	[self _calculateRollGroupPotentials:_group4Potentials withKeepGroupPotentials:_group5Potentials];
	[self _calculateKeepGroupPotentials:_group3Potentials withRollGroupPotentials:_group4Potentials];
	[self _calculateRollGroupPotentials:_group2Potentials withKeepGroupPotentials:_group3Potentials];
	[self _calculateWidgetPotential];
	return YES;
}

/**
 * Get the potential for a specific group and index.
 */
- (float)getGroupPotential:(int)group forIndex:(int)index {
	switch (group) {
		case 2: return _group2Potentials[index];
		case 3: return _group3Potentials[index];
		case 4: return _group4Potentials[index];
		case 5: return _group5Potentials[index];
		case 6: return _group6Potentials[index];
	}
	return -1;
}

/**
 * Get the next widget hash, for a current hash and using a specific category.
 */
+ (int)nextWidgetForScore:(int)score inCategory:(int)category withCurrentHash:(int)hash  {
	int categoryHash = (hash >> N_SCORE_BYTES);
	int newCategoryHash = categoryHash | (1 << category);
	
	int newScore = (hash & 63);
	if (category < N_SCORE_CATEGORIES) {
		newScore += score;
		if (newScore > 63) {
			newScore = 63;
		}
	}
	
	return newScore + (newCategoryHash << N_SCORE_BYTES);
}

@end
