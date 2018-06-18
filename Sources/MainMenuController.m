//
//  MainMenuController.m
//  iRoll
//
//  Created by Steven Roebert on 15/02/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//

#import "MainMenuController.h"
#import "GameModel.h"
#import "InfoViewController.h"
#import "Highscores.h"
#import "HighscoresViewController.h"
#import "SettingsViewController.h"

@implementation MainMenuController {
	BOOL _gameStateExists;
}

#pragma mark -
#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] 
								   initWithTitle:NSLocalizedString(@"MAIN_MENU_BACK_BUTTON", @"Main")
								   style:UIBarButtonItemStyleBordered target:nil action:nil];
	self.navigationItem.backBarButtonItem = backButton;
	
//	UIBarButtonItem *aboutButton = [[UIBarButtonItem alloc] 
//								   initWithTitle:@"About" 
//								   style:UIBarButtonItemStyleBordered target:self action:@selector(showAbout)];
//	self.navigationItem.leftBarButtonItem = aboutButton;
//	[aboutButton release];
	
	UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] 
									initWithTitle:NSLocalizedString(@"MAIN_MENU_SETTINGS_BUTTON", @"Settings")
									style:UIBarButtonItemStyleBordered target:self action:@selector(showSettings)];
	self.navigationItem.rightBarButtonItem = settingsButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	NSIndexPath *selectedPath = [_mainMenu indexPathForSelectedRow];
	[_mainMenu reloadData];
	
	_gameStateExists = [GameViewController stateFileExists];
	
	if (selectedPath != nil) {
		[_mainMenu selectRowAtIndexPath:selectedPath 
			animated:NO scrollPosition:UITableViewScrollPositionNone];
		[_mainMenu deselectRowAtIndexPath:selectedPath animated:YES];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	if (_gameStateExists != [GameViewController stateFileExists]) {
		[_mainMenu reloadData];
	}
}

#pragma mark TableView Feeding

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	// The main menu has 4 items
	return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
									   reuseIdentifier:@"cell"];
	}
	
	cell.textLabel.textColor = [UIColor blackColor];
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	
	// Get the different texts for the main menu items
	switch (indexPath.row) {
		case 0:
			cell.textLabel.text = NSLocalizedString(@"MAIN_MENU_NEW_GAME", @"New Game");
			break;
		case 1:
			cell.textLabel.text = NSLocalizedString(@"MAIN_MENU_CONTINUE_GAME", @"Continue Game");
			if (![GameViewController stateFileExists]) {
				cell.textLabel.textColor = [UIColor grayColor];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
			}
			break;
		case 2:
			cell.textLabel.text = NSLocalizedString(@"MAIN_MENU_HIGHSCORES", @"Highscores");
			if (![Highscores highscoresExists]) {
				cell.textLabel.textColor = [UIColor grayColor];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
			}
			break;
		case 3:
			cell.textLabel.text = NSLocalizedString(@"MAIN_MENU_RULES", @"Rules");
			break;
	}
	cell.textLabel.textAlignment = UITextAlignmentCenter;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Depending on which item the user selected, perform the appropriate action
	switch (indexPath.row) {
		case 0:
		{
			// Start a new game. Ask the user if the saved game can be overwritten if a 
			// saved game exists
			if ([GameViewController stateFileExists]) {
				UIActionSheet *actionSheet = [[UIActionSheet alloc] 
					initWithTitle:NSLocalizedString(@"NEW_GAME_OVERWRITE_TITLE", @"Saved game will be lost") delegate:self 
					cancelButtonTitle:NSLocalizedString(@"NEW_GAME_OVERWRITE_CANCEL", @"Cancel")
					destructiveButtonTitle:NSLocalizedString(@"NEW_GAME_OVERWRITE_CONFIRM", @"Continue")
					otherButtonTitles:nil];
				[actionSheet showInView:[self view]];
			}
			else {
				[self setupNewGame];
			}
		}
		break;
			
		case 1:
		{
			// Continue a game if a saved game exists
			if (![GameViewController stateFileExists]) {
				break;
			}
			
			// Create the GameViewController, try to restore the game state and push it onto
			// the navigation controller
			GameViewController *gameViewController = [self newGameViewController];
			if (![gameViewController restoreState]) {
				[GameViewController removeStateFiles];
				[_mainMenu deselectRowAtIndexPath:[_mainMenu indexPathForSelectedRow] animated:NO];
				[_mainMenu reloadData];
			}
			else {
				[self.navigationController pushViewController:gameViewController animated:YES];
			}
			
		}
		break;
			
		case 2:
		{
			if (![Highscores highscoresExists]) {
				break;
			}
			
			// Show the highscores page
			HighscoresViewController *highscoresViewController = [[HighscoresViewController alloc] 
																  initWithNibName:@"HighscoresViewController" bundle:nil];
			highscoresViewController.title = NSLocalizedString(@"HIGHSCORES_TITLE", @"Highscores");
			[self.navigationController pushViewController:highscoresViewController animated:YES];
		}
		break;
			
		case 3:
		{
			// Show the rules page
			InfoViewController *infoViewController = [[InfoViewController alloc] initWithText:NSLocalizedString(@"INFO_RULES", @"Rules")];
			infoViewController.title = NSLocalizedString(@"RULES_TITLE", @"Rules iRoll");
			[self.navigationController pushViewController:infoViewController animated:YES];
		}
		break;
	}
}

#pragma mark Utils

- (GameViewController *)newGameViewController {
	GameViewController *gameViewController = [[GameViewController alloc] 
											  initWithNibName:@"GameViewController" bundle:nil];
	gameViewController.title = NSLocalizedString(@"GAME_TITLE", @"Rolling Dice");
	return gameViewController;
}

- (void)setupNewGame {
	// Show the game setup controller for selecting the number of players.
	NewGameViewController *newGameViewController = 
		[[NewGameViewController alloc] initWithNibName:@"NewGameViewController" bundle:nil];
	newGameViewController.delegate = self;
	[self presentModalViewController:newGameViewController animated:YES];
}

#pragma mark User Actions

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.cancelButtonIndex) {
		[_mainMenu deselectRowAtIndexPath:[_mainMenu indexPathForSelectedRow] animated:YES];
	}
	else {
		[self setupNewGame];
	}
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet {
	[_mainMenu deselectRowAtIndexPath:[_mainMenu indexPathForSelectedRow] animated:YES];
}

- (void)startNewGameWithPlayers:(int)nPlayers andNames:(NSArray *)names {
	// Start a new game with the selected number of players.
	GameViewController *gameViewController = [self newGameViewController];
	
	GameModel *newGameModel = [[GameModel alloc] initWithPlayers:nPlayers];
	for (int i = 0; i < nPlayers; i++) {
		[newGameModel setName:names[i] forPlayer:i];
	}
	
	gameViewController.gameModel = newGameModel;
	[self.navigationController pushViewController:gameViewController animated:NO];
}

/*- (void)showAbout {
	InfoViewController *infoViewController = [[InfoViewController alloc] 
		initWithText:NSLocalizedString(@"INFO_ABOUT", @"About")];
	infoViewController.title = NSLocalizedString(@"ABOUT_TITLE", @"About iRoll");
	[self.navigationController pushViewController:infoViewController animated:YES];
	[infoViewController release];
}*/

- (void)showSettings {
	SettingsViewController *settingsViewController = [[SettingsViewController alloc] 
		initWithNibName:@"SettingsViewController" bundle:nil];
	settingsViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:settingsViewController animated:YES];
}

@end

