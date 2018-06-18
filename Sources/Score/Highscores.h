//
//  Highscores.h
//  iRoll
//
//  Created by Steven Roebert on 16/04/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//

#import "ScoreModel.h"

#define N_HIGHSCORES 10

@interface Highscore : NSObject <NSCoding>

@property (nonatomic, copy) NSString *player;
@property (nonatomic, strong) ScoreModel *score;

- (id)initWithScore:(ScoreModel *)scoreModel forPlayer:(NSString *)player;

@end

@interface Highscores : NSObject <NSCoding>

@property (nonatomic, readonly) NSArray *highscores;

+ (NSString *)highscoresFilePath;
+ (BOOL)highscoresExists;
+ (void)removeHighscores;
+ (Highscores *)loadHighscores;
+ (void)saveHighscores:(Highscores *)highscores;

- (void)addHighScore:(ScoreModel *)score forPlayer:(NSString *)player;
- (void)removeHighScoreAtIndex:(int)index;
- (void)clearHighscores;

@end
