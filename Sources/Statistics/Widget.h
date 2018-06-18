//
//  State.h
//  iRoll
//
//  Created by Steven Roebert on 02/03/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//
//	Class representing a widget from the state graph, discussed in my paper.
//

#import "DiceRoll.h"
#import "WidgetData.h"

#define MAX_DIE_VALUE 6
#define N_SCORE_BYTES 6
#define N_SCORE_CATEGORIES 6

struct WidgetState {
	int values[MAX_DIE_VALUE];
};
typedef struct WidgetState WidgetState;

@interface Widget : NSObject

@property (nonatomic, readonly) int totalUpperScore;
@property (nonatomic, readonly) float potential;
@property (nonatomic, readonly) WidgetData *widgetData;

- (void)_initGroupsAndEdges;

- (id)initFromHash:(int)hash;
- (id)initWithDataFile:(NSString *)file;
- (id)initFromHash:(int)hash withDataFile:(NSString *)file;
- (void)setHash:(int)hash;
- (void)saveWidgetDataToFile:(NSString *)file;

+ (BOOL)isValidHash:(int)hash;
- (BOOL)isValid;
- (BOOL)getCategoryFilledForIndex:(int)index;

+ (WidgetState)stateForDiceRoll:(DiceRoll)roll;
+ (DiceRoll)diceRollForState:(WidgetState)state;
+ (DiceRoll)diceRollForHash:(int)hash;
+ (int)hashForState:(WidgetState)state;
+ (WidgetState)stateForHash:(int)hash;

+ (BOOL)sortedArraySearch:(int *)array withCount:(int)count 
				 forValue:(int)value atIndex:(int *)index;
- (BOOL)calculatePotential:(float *)potentials;
- (float)getGroupPotential:(int)group forIndex:(int)index;
+ (int)nextWidgetForScore:(int)score inCategory:(int)category withCurrentHash:(int)hash;

@end
