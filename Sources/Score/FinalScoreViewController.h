//
//  FinalScoreOverviewController.h
//  iRoll
//
//  Created by Steven Roebert on 24/02/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//
//	ViewController containing a pagecontrol for scrolling through all the player scores.
//

#import "GameModel.h"
#import "CustomPageControl.h"

@interface FinalScoreViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) GameModel *gameModel;
@property (nonatomic, strong) IBOutlet UILabel *messageLabel;
@property (nonatomic, strong) IBOutlet UIScrollView *pageView;
@property (nonatomic, strong) IBOutlet CustomPageControl *pageControl;
@property (nonatomic, strong) IBOutlet UILabel *onesLabel, *twosLabel, *threesLabel, *foursLabel, 
	*fivesLabel, *sixesLabel, *bonusLabel, *threeOfAKindLabel, *fourOfAKindLabel, *fullHouseLabel,
	*smallStraightLabel, *largeStraightLabel, *fiveOfAKindLabel, *chanceLabel, *totalUpperLabel,
	*totalLowerLabel, *totalLabel;

- (void)loadPlayerScorePage:(int)page;
- (IBAction)changePage:(id)sender;
- (void)showWinningMessageForPlayer:(int)player;

@end
