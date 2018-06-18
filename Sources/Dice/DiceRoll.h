/*
 *  DiceRoll.h
 *  iRoll
 *
 *  Created by Steven Roebert on 20/02/2010.
 *  Copyright 2010 Steven Roebert. All rights reserved.
 *
 *	Struct used for holding a dice roll
 *
 */

#define DICE_COUNT 5

struct DiceRoll {
	int dice[DICE_COUNT];
};
typedef struct DiceRoll DiceRoll;