//
//  FinalScoreOverviewController.m
//  iRoll
//
//  Created by Steven Roebert on 24/02/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "FinalScoreViewController.h"
#import "FinalPlayerScoreViewController.h"

@implementation FinalScoreViewController {
	NSMutableArray *_playerScoreViewControllers;
	BOOL _pageControlUsed;
}

#pragma mark Init

- (void)viewDidLoad {
    [super viewDidLoad];
	
	_messageLabel.layer.cornerRadius = 10;
	_messageLabel.alpha = 0;
	
	_onesLabel.text = [NSLocalizedString(@"SCORES_ACES", @"Aces") stringByAppendingString:@":"];
	_twosLabel.text = [NSLocalizedString(@"SCORES_TWOS", @"Twos") stringByAppendingString:@":"];
	_threesLabel.text = [NSLocalizedString(@"SCORES_THREES", @"Threes") stringByAppendingString:@":"];
	_foursLabel.text = [NSLocalizedString(@"SCORES_FOURS", @"Fours") stringByAppendingString:@":"];
	_fivesLabel.text = [NSLocalizedString(@"SCORES_FIVES", @"Fives") stringByAppendingString:@":"];
	_sixesLabel.text = [NSLocalizedString(@"SCORES_SIXES", @"Sixes") stringByAppendingString:@":"];
	_bonusLabel.text = [NSLocalizedString(@"SCORES_BONUS", @"Bonus") stringByAppendingString:@":"];
	_threeOfAKindLabel.text = [NSLocalizedString(@"SCORES_3OFAKIND", @"3 of a Kind") stringByAppendingString:@":"];
	_fourOfAKindLabel.text = [NSLocalizedString(@"SCORES_4OFAKIND", @"4 of a Kind") stringByAppendingString:@":"];
	_fullHouseLabel.text = [NSLocalizedString(@"SCORES_FULLHOUSE", @"Full House") stringByAppendingString:@":"];
	_smallStraightLabel.text = [NSLocalizedString(@"SCORES_SMALLSTRAIGHT", @"Small Straight") stringByAppendingString:@":"];
	_largeStraightLabel.text = [NSLocalizedString(@"SCORES_LARGESTRAIGHT", @"Large Straight") stringByAppendingString:@":"];
	_fiveOfAKindLabel.text = [NSLocalizedString(@"SCORES_5OFAKIND", @"5 of a Kind") stringByAppendingString:@":"];
	_chanceLabel.text = [NSLocalizedString(@"SCORES_CHANCE", @"Chance") stringByAppendingString:@":"];
	_totalUpperLabel.text = [NSLocalizedString(@"SCORES_TOTAL_UPPER_SECTION", @"Total Upper Section") stringByAppendingString:@":"];
	_totalLowerLabel.text = [NSLocalizedString(@"SCORES_TOTAL_LOWER_SECTION", @"Total Lower Section") stringByAppendingString:@":"];
	_totalLabel.text = [NSLocalizedString(@"SCORES_TOTAL", @"Total") stringByAppendingString:@":"];
	
	_pageView.pagingEnabled = YES;
	_pageView.contentSize = CGSizeMake(
		_pageView.frame.size.width * _gameModel.nPlayers,
		_pageView.frame.size.height);
	_pageView.showsHorizontalScrollIndicator = NO;
    _pageView.showsVerticalScrollIndicator = NO;
	_pageView.scrollsToTop = NO;
	_pageView.delegate = self;
	_pageView.bounces = YES;
	
	_pageControl.numberOfPages = _gameModel.nPlayers;
	_pageControl.hidden = (_gameModel.nPlayers == 1);
    _pageControl.currentPage = 0;
	_pageControl.defaultDotColor = [UIColor grayColor];
	_pageControl.selectedDotColor = [UIColor blackColor];
	_pageControl.defersCurrentPageDisplay = YES;
	
	_playerScoreViewControllers = [[NSMutableArray alloc] initWithCapacity:_gameModel.nPlayers];
	for (int i = 0; i < _gameModel.nPlayers; i++) {
		[_playerScoreViewControllers addObject:[NSNull null]];
	}
	
	[self loadPlayerScorePage:0];
    [self loadPlayerScorePage:1];
	
	if (_gameModel.nPlayers > 1) {
		int winningPlayer = 0;
		int maxScore = [_gameModel getPlayerScore:0].totalScore;
		for (int i = 1; i < _gameModel.nPlayers; i++) {
			int playerScore = [_gameModel getPlayerScore:i].totalScore;
			if (playerScore > maxScore) {
				winningPlayer = i;
			}
		}
		
		BOOL tie = NO;
		for (int i = 0; i < _gameModel.nPlayers; i++) {
			if ([_gameModel getPlayerScore:i].totalScore == maxScore && i != winningPlayer) {
				tie = YES;
				break;
			}
		}
		
		if (!tie) {
			[self showWinningMessageForPlayer:winningPlayer];
		}
	}
}

#pragma mark Page Control

- (void)loadPlayerScorePage:(int)player {
    if (player < 0 || player >= _gameModel.nPlayers) {
		return;
	}
	
    // Replace the placeholder if necessary
    FinalPlayerScoreViewController *controller = _playerScoreViewControllers[player];
    if ((NSNull *)controller == [NSNull null])
    {
        controller = [[FinalPlayerScoreViewController alloc] init];
        [[NSBundle mainBundle] loadNibNamed:@"FinalPlayerScoreViewController" owner:controller options:nil];
		controller.playerName = [_gameModel getPlayerName:player];
		controller.playerScore = [_gameModel getPlayerScore:player];
        [controller setup];
        _playerScoreViewControllers[player] = controller;
    }
	
    // Add the controller's view to the scroll view
    if (nil == controller.view.superview) {
        CGRect frame = _pageView.frame;
        frame.origin.x = frame.size.width * player;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [_pageView addSubview:controller.view];
    }
}

- (IBAction)changePage:(id)sender {
    int page = _pageControl.currentPage;
	
    // Load the visible page and the page on either side of it
    [self loadPlayerScorePage:page - 1];
    [self loadPlayerScorePage:page];
    [self loadPlayerScorePage:page + 1];
    
	// Update the scroll view to the appropriate page
    CGRect frame = _pageView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [_pageView scrollRectToVisible:frame animated:YES];
    
    _pageControlUsed = YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _pageControlUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _pageControlUsed = NO;
	
	CGFloat pageWidth = _pageView.frame.size.width;
    _pageControl.currentPage = floor((_pageView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	[_pageControl updateCurrentPageDisplay];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	
	CGFloat pageWidth = _pageView.frame.size.width;
    _pageControl.currentPage = floor((_pageView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	[_pageControl updateCurrentPageDisplay];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    if (_pageControlUsed) {
        return;
    }
	
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = _pageView.frame.size.width;
    int page = floor((_pageView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	
    // Load the visible page and the page on either side of it
    [self loadPlayerScorePage:page - 1];
    [self loadPlayerScorePage:page];
    [self loadPlayerScorePage:page + 1];
}

#pragma mark Animation

/**
 * Animation for info messages.
 */

- (void)showWinningMessageForPlayer:(int)player
{
	_messageLabel.text = [NSString stringWithFormat:NSLocalizedString(@"FINAL_SCORE_PLAYER_HAS_WON_FORMAT", @"%@\nhas won!"), [_gameModel getPlayerName:player]];
    
    [UIView animateWithDuration:0.1 delay:0.5 options:0 animations:^{
        _messageLabel.alpha = 0.75;
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.4 delay:2 options:0 animations:^{
            _messageLabel.alpha = 0;
        } completion:NULL];
    }];
}

@end
