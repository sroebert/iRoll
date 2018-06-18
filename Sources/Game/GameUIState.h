//
//  GameUIState.h
//  iRoll
//
//  Created by Steven Roebert on 26/02/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//
//	GameUIState contains additional information (not included in GameModel) needed to save and 
//	load the game to and from disk.
//

#import "ScoreViewController.h"

@interface GameUIState : NSObject <NSCoding>

- (ScoreViewMode)getViewModeForPlayer:(int)player;
- (void)setViewMode:(ScoreViewMode)mode forPlayer:(int)player;

- (BOOL)getSelectedStateForDie:(int)die;
- (void)setSelectedState:(BOOL)state forDie:(int)die;

@end
