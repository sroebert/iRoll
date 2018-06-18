//
//  GameModel.h
//  iRoll
//
//  Created by Steven Roebert on 16/02/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//
//	The GameModel class holds the number of players, current player, current roll and
//	the scores for all the players.
//

#import "DiceRoll.h"
#import "ScoreModel.h"

@interface GameModel : NSObject <NSCoding>

@property (nonatomic, assign) DiceRoll diceRoll;
@property (nonatomic, readonly) int nPlayers;
@property (nonatomic, assign) int currentPlayer, currentRoll;
@property (readonly) BOOL isEndOfGame;

- (id)initWithPlayers:(int)players;
- (int)getDieValue:(int)index;
- (void)setDieValue:(int)index value:(int)value;
- (ScoreModel *)getPlayerScore:(int)player;
- (void)setScore:(ScoreModel *)score forPlayer:(int)player;
- (NSString *)getPlayerName:(int)player;
- (void)setName:(NSString *)name forPlayer:(int)player;

@end
