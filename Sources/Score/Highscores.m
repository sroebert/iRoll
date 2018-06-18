//
//  Highscores.m
//  iRoll
//
//  Created by Steven Roebert on 16/04/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//

#import "Highscores.h"

@implementation Highscore

#pragma mark Init

- (id)initWithScore:(ScoreModel *)scoreModel forPlayer:(NSString *)playerName
{
	if ((self = [super init]))
	{
		_score = scoreModel;
		_player = [playerName copy];
	}
	return self;
}

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:_player forKey:@"player"];
	[aCoder encodeObject:_score forKey:@"score"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super init])) {
		_player = [aDecoder decodeObjectForKey:@"player"];
		_score = [aDecoder decodeObjectForKey:@"score"];
	}
	return self;
}

#pragma mark Compare

- (NSComparisonResult)compareScore:(Highscore *)highScore {
	int otherTotalScore = highScore.score.totalScore;
	int totalScore = _score.totalScore;
	
	if (otherTotalScore < totalScore) {
		return NSOrderedAscending;
	}
	else if (otherTotalScore > totalScore) {
		return NSOrderedDescending;
	}
	return NSOrderedSame;
}

@end

@interface Highscores () {
    NSMutableArray *_highscores;
}

@end

@implementation Highscores

#pragma mark Save/Load

#pragma mark Highscores

+ (NSString *)highscoresFilePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = paths[0];
	NSString *highscoresFilePath = [documentsPath stringByAppendingPathComponent:@"highscores.data"];
	return highscoresFilePath;
}

+ (BOOL)highscoresExists {
	return [[NSFileManager defaultManager] fileExistsAtPath:[Highscores highscoresFilePath]];
}

+ (void)removeHighscores {
	if ([Highscores highscoresExists]) {
		[[NSFileManager defaultManager] removeItemAtPath:[Highscores highscoresFilePath] error:nil];
	}
}

+ (Highscores *)loadHighscores
{
	Highscores *highscores = nil;
	
	// Try to restore highscores from disk
	@try {
		highscores = [NSKeyedUnarchiver 
					  unarchiveObjectWithFile:[Highscores highscoresFilePath]];
	}
	@catch (NSException * e) {
		if (![e.name isEqualToString:@"NSInvalidArgumentException"]) {
			@throw e;
		}
	}
	
	if (highscores == nil) {
		highscores = [[Highscores alloc] init];
	}
	return highscores;
}

+ (void)saveHighscores:(Highscores *)highscores
{
	[NSKeyedArchiver archiveRootObject:highscores toFile:[Highscores highscoresFilePath]];
}

#pragma mark Init

- (id)init
{
	if ((self = [super init])) {
		_highscores = [[NSMutableArray alloc] initWithCapacity:N_HIGHSCORES];
	}
	return self;
}

- (NSArray *)highscores
{
    return _highscores;
}

#pragma mark Add

- (void)addHighScore:(ScoreModel *)score forPlayer:(NSString *)player
{
	Highscore *highScore = [[Highscore alloc] initWithScore:score forPlayer:player];
	[_highscores insertObject:highScore atIndex:0];
	
	[_highscores sortUsingSelector:@selector(compareScore:)];
	
	while ([_highscores count] > N_HIGHSCORES) {
		[_highscores removeLastObject];
	}
}

- (void)removeHighScoreAtIndex:(int)index
{
	[_highscores removeObjectAtIndex:index];
}

- (void)clearHighscores
{
	[_highscores removeAllObjects];
}

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:_highscores forKey:@"highscores"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super init])) {
		_highscores = [aDecoder decodeObjectForKey:@"highscores"];
	}
	return self;
}

@end
