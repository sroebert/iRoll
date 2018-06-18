//
//  FinalPlayerScoreViewController.h
//  iRoll
//
//  Created by Steven Roebert on 24/02/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//
//	Class contain the scores for a particular player.
//

#import "ScoreModel.h"

@interface FinalPlayerScoreViewController : NSObject

- (void)setup;

@property (nonatomic, copy) NSString *playerName;
@property (nonatomic, strong) ScoreModel *playerScore;

@property (nonatomic, strong) IBOutlet UIView *view;

@property (nonatomic, strong) IBOutlet UINavigationItem *playerNameItem;
@property (nonatomic, strong) IBOutlet UILabel *onesLabel, *twosLabel, *threesLabel, *foursLabel,
	*fivesLabel, *sixesLabel, *bonusLabel, *threeOfAKindLabel, *fourOfAKindLabel, *fullHouseLabel,
	*smallStraightLabel, *largeStraightLabel, *fiveOfAKindLabel, *chanceLabel, *totalUpperLabel,
	*totalLowerLabel, *totalLabel;

@end
