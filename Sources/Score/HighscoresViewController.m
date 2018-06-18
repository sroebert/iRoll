//
//  HighscoresViewController.m
//  iRoll
//
//  Created by Steven Roebert on 16/04/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//

#import "HighscoresViewController.h"
#import "FinalScoreViewController.h"
#import "GameModel.h"
#import "Highscores.h"

@interface HighscoresViewController () {
    Highscores *_highscores;
}

- (void)finishEditHighscores;

@end


@implementation HighscoresViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		_highscores = [Highscores loadHighscores];
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"HIGHSCORES_EDITING_EDIT", @"Edit") style:UIBarButtonItemStyleBordered target:self action:@selector(editHighscores)];
	self.navigationItem.rightBarButtonItem = editButton;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_highscores.highscores count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"highscore"];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"highscore"];
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

		CGRect cellBounds = cell.contentView.bounds;
		CGRect frame = CGRectMake(cellBounds.size.width - 120, 0, 60, cellBounds.size.height);
		
		UILabel *label = [[UILabel alloc] initWithFrame:frame];
		label.textAlignment = UITextAlignmentRight;
		label.textColor = [UIColor blackColor];
		label.highlightedTextColor = [UIColor whiteColor];
		label.tag = 1;
		label.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:label];
	}
	
	if ([_highscores.highscores count] > indexPath.row) {
		Highscore *score = (_highscores.highscores)[indexPath.row];
		UILabel *scoreLabel = (UILabel *)[cell.contentView viewWithTag:1];
		
		cell.textLabel.text = [NSString stringWithFormat:@"%2d. %@", indexPath.row + 1, score.player];
		scoreLabel.text = [NSString stringWithFormat:@"%d", score.score.totalScore];
		
		[cell.contentView bringSubviewToFront:scoreLabel];
	}

	return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	FinalScoreViewController *finalScoreViewController = 
		[[FinalScoreViewController alloc] initWithNibName:@"FinalScoreViewController" bundle:nil];
	finalScoreViewController.title = [NSString stringWithFormat:@"%@ %d", NSLocalizedString(@"HIGHSCORES_VIEW_SCORE_TITLE", @"Highscore"), indexPath.row + 1];
	
	GameModel *gameModel = [[GameModel alloc] initWithPlayers:1];
	Highscore *highscore = (_highscores.highscores)[indexPath.row];
	[gameModel setScore:highscore.score forPlayer:0];
	[gameModel setName:highscore.player forPlayer:0];
	
	finalScoreViewController.gameModel = gameModel;
	
	[self.navigationController pushViewController:finalScoreViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView
	commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
	forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[_highscores removeHighScoreAtIndex:indexPath.row];
		[Highscores saveHighscores:_highscores];
		
		[tableView beginUpdates];
		
		if ([_highscores.highscores count] == 0) {
			[Highscores removeHighscores];
		}
		[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
		
		[tableView endUpdates];
	}
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return @[ @"A", @"B", @"C", @"D", @"E", @"A", @"B", @"C", @"D", @"E", @"A", @"B", @"C", @"D", @"E", @"A", @"B", @"C", @"D", @"E", @"A", @"B", @"C", @"D", @"E", @"A", @"B", @"C", @"D", @"E", @"A", @"B", @"C", @"D", @"E", @"A", @"B", @"C", @"D", @"E",  ];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return 0;
}

#pragma mark -
#pragma mark Edit

- (void)editHighscores
{
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"HIGHSCORES_EDITING_DONE", @"Done") style:UIBarButtonItemStyleDone target:self action:@selector(finishEditHighscores)];
	self.navigationItem.rightBarButtonItem = doneButton;
	
	UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"HIGHSCORES_EDITING_CLEAR", @"Clear All") style:UIBarButtonItemStyleBordered target:self action:@selector(clearHighscores)];
	self.navigationItem.leftBarButtonItem = clearButton;
	
	[self.tableView setEditing:YES animated:YES];
}

- (void)finishEditHighscores
{
	[self.tableView setEditing:NO animated:YES];
	
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"HIGHSCORES_EDITING_EDIT", @"Edit") style:UIBarButtonItemStyleBordered target:self action:@selector(editHighscores)];
	self.navigationItem.rightBarButtonItem = editButton;
	
	self.navigationItem.leftBarButtonItem = nil;
}

- (void)clearHighscores
{
	UIAlertView *alertView = [[UIAlertView alloc] 
		initWithTitle:NSLocalizedString(@"HIGHSCORES_CLEAR_ALERT_TITLE", @"Clear Highscores")
		message:NSLocalizedString(@"HIGHSCORES_CLEAR_ALERT_MESSAGE", @"Are you sure you want to clear all highscores?\nThis can not be undone!")
		delegate:self cancelButtonTitle:NSLocalizedString(@"HIGHSCORES_CLEAR_ALERT_CANCEL", @"NO") 
		otherButtonTitles:NSLocalizedString(@"HIGHSCORES_CLEAR_ALERT_CONFIRM", @"YES"), nil];
	[alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == alertView.firstOtherButtonIndex)
	{
		[self.tableView beginUpdates];
		
		int counter = [_highscores.highscores count];
		for (NSInteger i = counter - 1; i >= 0; i--) {
			[_highscores removeHighScoreAtIndex:i];
			[self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
		}
		[Highscores removeHighscores];
		 
		[self.tableView endUpdates];
		
		[self finishEditHighscores];
	}
}

#pragma mark -
#pragma mark Memory management



@end

