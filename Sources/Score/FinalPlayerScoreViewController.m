//
//  FinalPlayerScoreViewController.m
//  iRoll
//
//  Created by Steven Roebert on 24/02/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//

#import "FinalPlayerScoreViewController.h"


@implementation FinalPlayerScoreViewController

- (void)setup
{
    // Load all scores from the ScoreModel
    _playerNameItem.title = _playerName;
    _onesLabel.text =			[NSString stringWithFormat:@"%d", [_playerScore getScoreWithIndex:0]];
    _twosLabel.text =			[NSString stringWithFormat:@"%d", [_playerScore getScoreWithIndex:1]];
    _threesLabel.text =			[NSString stringWithFormat:@"%d", [_playerScore getScoreWithIndex:2]];
    _foursLabel.text =			[NSString stringWithFormat:@"%d", [_playerScore getScoreWithIndex:3]];
    _fivesLabel.text =			[NSString stringWithFormat:@"%d", [_playerScore getScoreWithIndex:4]];
    _sixesLabel.text =			[NSString stringWithFormat:@"%d", [_playerScore getScoreWithIndex:5]];
    _threeOfAKindLabel.text =	[NSString stringWithFormat:@"%d", [_playerScore getScoreWithIndex:6]];
    _fourOfAKindLabel.text =		[NSString stringWithFormat:@"%d", [_playerScore getScoreWithIndex:7]];
    _fullHouseLabel.text =		[NSString stringWithFormat:@"%d", [_playerScore getScoreWithIndex:8]];
    _smallStraightLabel.text =	[NSString stringWithFormat:@"%d", [_playerScore getScoreWithIndex:9]];
    _largeStraightLabel.text =	[NSString stringWithFormat:@"%d", [_playerScore getScoreWithIndex:10]];
    _fiveOfAKindLabel.text =		[NSString stringWithFormat:@"%d", [_playerScore getScoreWithIndex:11]];
    _chanceLabel.text =			[NSString stringWithFormat:@"%d", [_playerScore getScoreWithIndex:12]];
    
    _bonusLabel.text =			[NSString stringWithFormat:@"%d", _playerScore.bonusScore];
    _totalUpperLabel.text =		[NSString stringWithFormat:@"%d", _playerScore.upperTotalScore];
    _totalLowerLabel.text =		[NSString stringWithFormat:@"%d", _playerScore.lowerTotalScore];
    _totalLabel.text =			[NSString stringWithFormat:@"%d", _playerScore.totalScore];
}

@end
