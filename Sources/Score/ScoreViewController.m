//
//  ScoreViewController.m
//  iRoll
//
//  Created by Steven Roebert on 19/02/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//

#import "ScoreViewController.h"
#import "Utils.h"
#import "ScoreSuggestion.h"

@implementation ScoreViewController {
	NSMutableArray *_scoreImagesNormal, *_scoreImagesSelected, *_scoreImagesDisabled;
	int _filledScores;
}

- (void)setViewMode:(ScoreViewMode)mode {
	_viewMode = mode;
	[_viewModeControl setSelectedSegmentIndex:(int)mode];
	[_scoreView reloadData];
	[_scoreView setContentOffset:CGPointMake(0, 0) animated:NO];
}

- (void)setScoreSuggestions:(NSArray *)suggestions {
	_scoreSuggestions = suggestions;
	_filledScores = 0;
	for (ScoreSuggestion *suggestion in _scoreSuggestions) {
		if ([suggestion.score intValue] == -1) {
			_filledScores++;
		}
	}
}

#pragma mark Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		_delegate = nil;
		_scoreView = nil;
		_viewModeControl = nil;
		
		_scoreImagesNormal = [[NSMutableArray alloc] initWithCapacity:SCORE_TYPE_COUNT];
		_scoreImagesSelected = [[NSMutableArray alloc] initWithCapacity:SCORE_TYPE_COUNT];
		_scoreImagesDisabled = [[NSMutableArray alloc] initWithCapacity:SCORE_TYPE_COUNT];
		
		UIImage *blackImage = [Utils createImageWithColor:[UIColor blackColor] width:38 height:34];
		UIImage *whiteImage = [Utils createImageWithColor:[UIColor whiteColor] width:38 height:34];
		UIImage *grayImage = [Utils createImageWithColor:[UIColor grayColor] width:38 height:34];
		
		for (int i = 0; i < SCORE_TYPE_COUNT; i++) {
			UIImage *scoreImage = [UIImage imageNamed:[NSString stringWithFormat:@"score_%02d.png", i]];
			[_scoreImagesNormal addObject:[Utils maskImage:blackImage withMask:scoreImage]];
			[_scoreImagesSelected addObject:[Utils maskImage:whiteImage withMask:scoreImage]];
			[_scoreImagesDisabled addObject:[Utils maskImage:grayImage withMask:scoreImage]];
		}
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SCORES_SAVE_BUTTON", @"Save") style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonClick)];
	_navBar.topItem.rightBarButtonItem = saveButton;
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SCORES_CANCEL_BUTTON", @"Cancel") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonClick)];
	_navBar.topItem.leftBarButtonItem = cancelButton;
	
	[_viewModeControl setTitle:NSLocalizedString(@"SCORES_MODE_DEFAULT", @"Default") forSegmentAtIndex:0];
	[_viewModeControl setTitle:NSLocalizedString(@"SCORES_MODE_SUGGESTED", @"Suggested") forSegmentAtIndex:1];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (_scoreSuggestions == nil) {
		_viewMode = ScoreViewModeDefault;
		_viewModeControl.hidden = YES;
	}
	else {
		_viewModeControl.hidden = NO;
	}
	
	[_diceButton1 setDieValue:_diceRoll.dice[0] animated:NO];
	[_diceButton2 setDieValue:_diceRoll.dice[1] animated:NO];
	[_diceButton3 setDieValue:_diceRoll.dice[2] animated:NO];
	[_diceButton4 setDieValue:_diceRoll.dice[3] animated:NO];
	[_diceButton5 setDieValue:_diceRoll.dice[4] animated:NO];
	_navBar.topItem.rightBarButtonItem.enabled = NO;
	
	[_scoreView setContentOffset:CGPointMake(0, 0) animated:NO];
	
	self.viewMode = _viewMode;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[_scoreView flashScrollIndicators];
}

#pragma mark User Actions

- (IBAction)saveButtonClick {
	int index = [self getScoreIndexForIndexPath:[_scoreView indexPathForSelectedRow]];
	[_delegate saveScoreForIndex:index];
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)cancelButtonClick {
	if ([_delegate respondsToSelector:@selector(cancelSaveScore)]) {
		[_delegate cancelSaveScore];
	}
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)viewModeClick {
	self.viewMode = (ScoreViewMode)_viewModeControl.selectedSegmentIndex;
	_navBar.topItem.rightBarButtonItem.enabled = NO;
	if ([_delegate respondsToSelector:@selector(changeViewMode:)]) {
		[_delegate changeViewMode:self.viewMode];
	}
    [_scoreView flashScrollIndicators];
}

#pragma mark TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	switch (_viewMode) {
		case ScoreViewModeDefault:
			return 5;
		case ScoreViewModeSuggested:
			return 3;
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (_viewMode) {
		case ScoreViewModeDefault:
			switch (section) {
				case 0: return NSLocalizedString(@"SCORES_UPPER_SECTION", @"Upper Section");
				case 1: return NSLocalizedString(@"SCORES_UPPER_SECTION_SUMMARY", @"Upper Section Summary");
				case 2: return NSLocalizedString(@"SCORES_LOWER_SECTION", @"Lower Section");
				case 3: return NSLocalizedString(@"SCORES_LOWER_SECTION_SUMMARY", @"Lower Section Summary");
				case 4: return NSLocalizedString(@"SCORES_TOTAL", @"Total");
			}
		case ScoreViewModeSuggested:
			switch (section) {
				case 0: return NSLocalizedString(@"SCORES_SUGGESTIONS", @"Suggestions");
				case 1: return NSLocalizedString(@"SCORES_FILLED", @"Filled");
				case 2: return NSLocalizedString(@"SCORES_SUMMARY", @"Summary");
			}
	}
	return nil;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	switch (_viewMode) {
		case ScoreViewModeDefault:
			switch (section) {
				case 0: return 6;
				case 1: return 2;
				case 2: return 7;
				case 3: return 1;
				case 4: return 1;
			}
		case ScoreViewModeSuggested:
			switch (section) {
				case 0: return SCORE_TYPE_COUNT - _filledScores;
				case 1: return _filledScores;
				case 2: return 4;
			}
	}
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	int scoreTag = 1;
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:@"cell"];
		
		CGRect cellBounds = cell.contentView.bounds;
		CGRect frame = CGRectMake(cellBounds.size.width - 100, 0, 60, cellBounds.size.height);
		UILabel *label = [[UILabel alloc] initWithFrame:frame];
		label.textAlignment = UITextAlignmentRight;
		label.highlightedTextColor = [UIColor whiteColor];
		label.backgroundColor = [UIColor clearColor];
		label.tag = scoreTag;
		[cell.contentView addSubview:label];
	}
	
	UILabel *label = (UILabel *)[cell.contentView viewWithTag:scoreTag];
	
	int score = 0;
	if (_viewMode == ScoreViewModeDefault && 
		(indexPath.section == 1 || indexPath.section == 3 || indexPath.section == 4))
	{
		switch (indexPath.section) {
			case 1:
				if (indexPath.row == 0) {
					score = _scoreModel.bonusScore;
					cell.textLabel.text = NSLocalizedString(@"SCORES_BONUS", @"Bonus");
				}
				else {
					score = _scoreModel.upperTotalScore;
					cell.textLabel.text = NSLocalizedString(@"SCORES_TOTAL_UPPER_SECTION", @"Total Upper Section");
				}
				break;
			case 3:
				score = _scoreModel.lowerTotalScore;
				cell.textLabel.text = NSLocalizedString(@"SCORES_TOTAL_LOWER_SECTION", @"Total Lower Section");
				break;
			case 4:
				score = _scoreModel.totalScore;
				cell.textLabel.text = NSLocalizedString(@"SCORES_TOTAL_SCORE", @"Total Score");
				break;
		}
		
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.imageView.image = nil;
		cell.imageView.highlightedImage = nil;
		
		label.textColor = [UIColor blackColor];
	}
	else if (_viewMode == ScoreViewModeSuggested && indexPath.section == 2) {
		switch (indexPath.row) {
			case 0:
				score = _scoreModel.bonusScore;
				cell.textLabel.text = NSLocalizedString(@"SCORES_BONUS", @"Bonus");
				break;
			case 1:
				score = _scoreModel.upperTotalScore;
				cell.textLabel.text = NSLocalizedString(@"SCORES_TOTAL_UPPER_SECTION", @"Total Upper Section");
				break;
			case 2:
				score = _scoreModel.lowerTotalScore;
				cell.textLabel.text = NSLocalizedString(@"SCORES_TOTAL_LOWER_SECTION", @"Total Lower Section");
				break;
			case 3:
				score = _scoreModel.totalScore;
				cell.textLabel.text = NSLocalizedString(@"SCORES_TOTAL_SCORE", @"Total Score");
				break;
		}
		
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.imageView.image = nil;
		cell.imageView.highlightedImage = nil;
		
		label.textColor = [UIColor blackColor];
	}
	else {
		int index = [self getScoreIndexForIndexPath:indexPath];
		NSString *scoreName = [_scoreModel getScoreNameForIndex:index];
		cell.textLabel.text = scoreName;
		score = [_scoreModel getScoreWithName:scoreName];
		
		if (score > -1) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.imageView.image = _scoreImagesDisabled[index];
			cell.imageView.highlightedImage = _scoreImagesDisabled[index];
		}
		else {
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.imageView.image = _scoreImagesNormal[index];
			cell.imageView.highlightedImage = _scoreImagesSelected[index];
			score = [ScoreModel getScoreWithIndex:index forDiceRoll:_diceRoll];
		}
		
		label.textColor = [UIColor grayColor];
	}
	
	[label setText:[NSString stringWithFormat:@"%d", score]];
	[cell.contentView bringSubviewToFront:label];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (_viewMode == ScoreViewModeDefault && 
		(indexPath.section == 1 || indexPath.section == 3 || indexPath.section == 4))
	{
		cell.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
		cell.textLabel.textColor = [UIColor blackColor];
	}
	else if (cell.selectionStyle == UITableViewCellSelectionStyleBlue) {
		cell.backgroundColor = [UIColor whiteColor];
		cell.textLabel.textColor = [UIColor blackColor];
	}
	else {
		cell.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
		cell.textLabel.textColor = [UIColor grayColor];
	}
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSIndexPath *currentlySelected = [tableView indexPathForSelectedRow];
	[tableView deselectRowAtIndexPath:currentlySelected animated:NO];
	
	if (_viewMode == ScoreViewModeDefault && 
		(indexPath.section == 1 || indexPath.section == 3 || indexPath.section == 4)) {
		return currentlySelected;
	}
	
	int index = [self getScoreIndexForIndexPath:indexPath];
	
	NSString *scoreName = [_scoreModel getScoreNameForIndex:index];
	int score = [_scoreModel getScoreWithName:scoreName];
	BOOL finalScore = (score > -1);
	
	if (finalScore) {
		return currentlySelected;
	}
	return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([ScoreModel countDiceRollTotal:_diceRoll] != 0) {
		_navBar.topItem.rightBarButtonItem.enabled = YES;
	}
}

#pragma mark Utils

- (int)getScoreIndexForIndexPath:(NSIndexPath *)indexPath {	
	if (_viewMode == ScoreViewModeDefault) {
		int index = indexPath.row;
		if (indexPath.section != 0) {
			index += 6;
		}
		return index;
	}
	else if (_viewMode == ScoreViewModeSuggested) {
		int objectIndex = indexPath.row;
		if (indexPath.section != 0) {
			objectIndex += (SCORE_TYPE_COUNT - _filledScores);
		}
		ScoreSuggestion *suggestion = _scoreSuggestions[objectIndex];
		return [suggestion.scoreIndex intValue];
	}
	return -1;
}

@end
