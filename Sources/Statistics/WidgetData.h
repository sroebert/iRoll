//
//  WidgetData.h
//  iRoll
//
//  Created by Steven Roebert on 17/03/2010.
//  Copyright 2010 Apple Inc. All rights reserved.
//
//	Data that will be the same for each widget, namely the internal roll and keep state hashes and
//	edges between these states. This class is used to save the data to disk. This way the iPhone
//	does not have to calculate this information, but can simply load it from disk.
//

#define N_ROLL_STATES 252
#define N_KEEP_STATES 462
#define MAX_ROLL2KEEP 32
#define MAX_KEEP2ROLL 252

struct WidgetDataStruct {
	int rollStates[N_ROLL_STATES], keepStates[N_KEEP_STATES];
	
	int roll2KeepCounts[N_ROLL_STATES];
	int roll2KeepEdges[N_ROLL_STATES][MAX_ROLL2KEEP];
	
	int keep2RollCounts[N_KEEP_STATES];
	int keep2RollEdges[N_KEEP_STATES][MAX_KEEP2ROLL];
};
typedef struct WidgetDataStruct WidgetDataStruct;

@interface WidgetData : NSObject

@property (nonatomic, readonly) WidgetDataStruct *data;

- (BOOL)saveToFile:(NSString *)path;
- (BOOL)loadFromFile:(NSString *)path;

@end
