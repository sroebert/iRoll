//
//  GameViewController.m
//  iRoll
//
//  Created by Steven Roebert on 15/02/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>

#import "GameViewController.h"
//#import "DiceScanner.h"
#import "ImageViewController.h"
#import "Highscores.h"
#import "Utils.h"
#import "Settings.h"
#import "FinalScoreViewController.h"
#import "GameUIState.h"
#import "DiceRoll.h"
#import "GameStatistics.h"
#import "Widget.h"
#import "KeepSuggestion.h"

@implementation GameViewController {
	NSArray *_dieButtons;
	GameUIState *_gameUIState;
	
	int _dieAnimationCounter;
	int _currentDieAnimationCount;
	
	DiceRoll _diceRecognitionResult;
	UIImagePickerControllerSourceType _recognitionSourceType;
	BOOL _showPlayerMessageFirstTime;
	
	GameStatistics *_statistics;
	NSArray *_keepSuggestions;
	NSMutableArray *_keepImagesNormal, *_keepImagesHighlighted;
	
	int _shakeCount;
	BOOL _audioAvailable;
	NSURL *_shakeAudioUrl, *_rollAudioUrl;
	SystemSoundID _shakeAudioID, _rollAudioID;
	
	BOOL _suggestionsOn, _shakeToRollOn, _rollSoundOn, _shakeSoundOn, _vibrateWhenShakeOn;
}

#pragma mark -
#pragma mark Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		_gameModel = [[GameModel alloc] initWithPlayers:1];
		_gameUIState = [[GameUIState alloc] init];
		_showPlayerMessageFirstTime = YES;
		
		_recognitionSourceType = UIImagePickerControllerSourceTypeCamera;
		//recognitionSourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		
		_keepImagesNormal = [[NSMutableArray alloc] initWithCapacity:N_SCORE_CATEGORIES];
		_keepImagesHighlighted = [[NSMutableArray alloc] initWithCapacity:N_SCORE_CATEGORIES];
		
		UIImage *blackImage = [Utils createImageWithColor:[UIColor blackColor] width:38 height:34];
		UIImage *whiteImage = [Utils createImageWithColor:[UIColor whiteColor] width:38 height:34];
		
		for (int i = 0; i < N_SCORE_CATEGORIES; i++) {
			UIImage *scoreImage = [UIImage imageNamed:[NSString stringWithFormat:@"score_%02d.png", i]];
			[_keepImagesNormal addObject:[Utils maskImage:blackImage withMask:scoreImage]];
			[_keepImagesHighlighted addObject:[Utils maskImage:whiteImage withMask:scoreImage]];
		}
		
		NSString *shakeAudioPath = [[NSBundle mainBundle] pathForResource:@"shake" ofType:@"aiff"];
		_shakeAudioUrl = [NSURL fileURLWithPath:shakeAudioPath];
		NSString *rollAudioPath = [[NSBundle mainBundle] pathForResource:@"roll" ofType:@"aiff"];
		_rollAudioUrl = [NSURL fileURLWithPath:rollAudioPath];
		
		AudioServicesCreateSystemSoundID((__bridge CFURLRef)_shakeAudioUrl, &_shakeAudioID);
		AudioServicesCreateSystemSoundID((__bridge CFURLRef)_rollAudioUrl, &_rollAudioID);
		_audioAvailable = YES;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
	}
	return self;
}

#pragma mark Save/Restore State

+ (NSString *)stateFilePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = paths[0];
	NSString *stateFilePath = [documentsPath stringByAppendingPathComponent:@"gameState.data"];
	return stateFilePath;
}

+ (NSString *)uiStateFilePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = paths[0];
	NSString *stateFilePath = [documentsPath stringByAppendingPathComponent:@"uiState.data"];
	return stateFilePath;
}

+ (BOOL)stateFileExists {
	return [[NSFileManager defaultManager] fileExistsAtPath:[GameViewController stateFilePath]];
}

+ (BOOL)uiStateFileExists {
	return [[NSFileManager defaultManager] fileExistsAtPath:[GameViewController uiStateFilePath]];
}

+ (void)removeStateFiles {
	if ([GameViewController stateFileExists]) {
		[[NSFileManager defaultManager] 
		 removeItemAtPath:[GameViewController stateFilePath] error:nil];
	}
	if ([GameViewController uiStateFileExists]) {
		[[NSFileManager defaultManager] 
		 removeItemAtPath:[GameViewController uiStateFilePath] error:nil];
	}
}

- (void)saveState {
	// Save game state to disk, if it is not the end of the game
	if (!_gameModel.isEndOfGame) {
		[NSKeyedArchiver archiveRootObject:_gameModel toFile:[GameViewController stateFilePath]];
		[NSKeyedArchiver archiveRootObject:_gameUIState toFile:[GameViewController uiStateFilePath]];
	}
}

- (BOOL)restoreState {
	
	// Try to restore the game from disk
	@try {
		GameModel *loadedModel = [NSKeyedUnarchiver 
			unarchiveObjectWithFile:[GameViewController stateFilePath]];
		if (loadedModel != nil) {
			self.gameModel = loadedModel;
		}
		else {
			return NO;
		}
	}
	@catch (NSException * e) {
		if (![e.name isEqualToString:@"NSInvalidArgumentException"]) {
			@throw e;
		}
		return NO;
	}
	
	@try {
		GameUIState *loadedUIState = [NSKeyedUnarchiver 
			unarchiveObjectWithFile:[GameViewController uiStateFilePath]];
		
		if (loadedUIState != nil) {
			_gameUIState = loadedUIState;
		}
	}
	@catch (NSException * e) {
		if (![e.name isEqualToString:@"NSInvalidArgumentException"]) {
			@throw e;
		}
	}
	
	return YES;
}

#pragma mark View/Motions

/**
 * Initialize the UI
 */
- (void)viewDidLoad {
	[super viewDidLoad];
	
//	if ([UIImagePickerController isSourceTypeAvailable:recognitionSourceType]) {
//		UIBarButtonItem *makePictureButton = [[UIBarButtonItem alloc] 
//			initWithBarButtonSystemItem:UIBarButtonSystemItemCamera 
//			target:self action:@selector(loadPicture)];
//		self.navigationItem.rightBarButtonItem = makePictureButton;
//		[makePictureButton release];
//	}
	
	[_rollButton setTitle:NSLocalizedString(@"GAME_ROLL_BUTTON", @"Roll") forState:UIControlStateNormal];
	[_scoreButton setTitle:NSLocalizedString(@"GAME_SCORE_BUTTON", @"Score") forState:UIControlStateNormal];
	_cameraMessageLabel.text = [NSLocalizedString(@"GAME_PROCESSING_IMAGE_LABEL", @"processing image...") stringByAppendingString:@"  "];
	
	Settings *settings = [Settings loadSettings];
	_suggestionsOn = [[settings getValueForKey:@"ShowSuggestions"] boolValue];
	_shakeToRollOn = [[settings getValueForKey:@"ShakeToRoll"] boolValue];
	_rollSoundOn = [[settings getValueForKey:@"RollSound"] boolValue];
	_shakeSoundOn = [[settings getValueForKey:@"ShakeSound"] boolValue];
	_vibrateWhenShakeOn = [[settings getValueForKey:@"VibrateWhenShake"] boolValue];
	
	_messageLabel.layer.cornerRadius = 10;
	_messageLabel.alpha = 0;
	
	_cameraMessageLabel.layer.cornerRadius = 10;
	_cameraMessageLabel.alpha = 0;
	_cameraActivityView.alpha = 0;
	
	_shakeCount = 0;
	
	_dieButtons = [[NSArray alloc] initWithObjects:
				   _dieButton1, _dieButton2, _dieButton3, _dieButton4, _dieButton5, nil];
	for (int i = 0; i < DICE_COUNT; i++) {
		DieButton *dieButton = _dieButtons[i];
		dieButton.tag = i;
		[dieButton setDieValue:[_gameModel getDieValue:i] animated:NO];
		dieButton.delegate = self;
	}
	
	[self updateUI];
}

//- (BOOL)canBecomeFirstResponder {
//	return YES;
//}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
//	[self becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (_showPlayerMessageFirstTime) {
		_showPlayerMessageFirstTime = NO;
		if (_gameModel.nPlayers > 1) {
			[self showCurrentPlayerMessage];
		}
	}
}

- (void)didBecomeActive:(NSNotification *)notification {
	
	// Make sure we show the current player message if the application returns from the background
	if (_gameModel.nPlayers > 1) {
		if (self.modalViewController) {
			_showPlayerMessageFirstTime = YES;
		}
		else {
			[self showCurrentPlayerMessage];
		}
	}
}

/**
 * Shaking results in rolling the dice.
 */
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	if (motion == UIEventSubtypeMotionShake)
	{
		if (!_shakeToRollOn || !_rollButton.enabled) {
			return;
		}
		
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetShake) object:nil];
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(shakingDice) object:nil];
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rollDice) object:nil];
		[self shakingDice];
	}
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	if (motion == UIEventSubtypeMotionShake)
	{
		if (!_shakeToRollOn || !_rollButton.enabled) {
			return;
		}
		
		if (_shakeCount > 1) {
			[self performSelector:@selector(rollDice) withObject:nil afterDelay:0.5];
		}
		
		[self performSelector:@selector(resetShake) withObject:nil afterDelay:0.5];
	}
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	if (motion == UIEventSubtypeMotionShake)
	{
		if (!_shakeToRollOn || !_rollButton.enabled) {
			return;
		}
		
		if (_shakeCount > 1) {
			[self performSelector:@selector(rollDice) withObject:nil afterDelay:0.5];
		}
		
		[self performSelector:@selector(resetShake) withObject:nil afterDelay:0.5];
	}
}

- (void)resetShake
{
	_shakeCount = 0;
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(shakingDice) object:nil];
}

- (void)shakingDice
{
	_shakeCount++;
	[self performSelector:@selector(shakingDice) withObject:nil afterDelay:0.5];
	
	if (!_audioAvailable) {
		AudioServicesCreateSystemSoundID((__bridge CFURLRef)_shakeAudioUrl, &_shakeAudioID);
		AudioServicesCreateSystemSoundID((__bridge CFURLRef)_rollAudioUrl, &_rollAudioID);
		_audioAvailable = YES;
	}
	
	if (_shakeSoundOn) {
		AudioServicesPlaySystemSound(_shakeAudioID);
		if (_vibrateWhenShakeOn) {
			AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
		}
	}
}

#pragma mark Game Control

/**
 * Update the UI, enabling and disabling buttons, changing text, based on the current state.
 */
- (void)updateUI {
	_rollButton.enabled = (_gameModel.currentRoll < 3);
	_scoreButton.enabled = YES;
	
	BOOL dieButtonsEnabled = (_gameModel.currentRoll != 0 && _gameModel.currentRoll != 3);
	for (int i = 0; i < DICE_COUNT; i++) {
		DieButton *dieButton = _dieButtons[i];
		dieButton.enabled = dieButtonsEnabled;
		dieButton.selected = ([_gameUIState getSelectedStateForDie:i] && dieButtonsEnabled);
		[dieButton setNeedsDisplay];
	}
	
	_playerLabel.text = [_gameModel getPlayerName:-1];
	if (3 - _gameModel.currentRoll == 1) {
		_rollLabel.text = [NSString stringWithFormat:@"1 %@", NSLocalizedString(@"GAME_ROLL", @"roll")];
	}
	else {
		_rollLabel.text = [NSString stringWithFormat:@"%d %@", 3 - _gameModel.currentRoll, NSLocalizedString(@"GAME_ROLLS", @"rolls")];
	}
	
	[self calculateGameStrategy];
}

/**
 * Roll the dice.
 */
- (IBAction)rollDice {
	if (!_rollButton.enabled) {
		return;
	}
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(shakingDice) object:nil];
	if (!_audioAvailable) {
		AudioServicesCreateSystemSoundID((__bridge CFURLRef)_shakeAudioUrl, &_shakeAudioID);
		AudioServicesCreateSystemSoundID((__bridge CFURLRef)_rollAudioUrl, &_rollAudioID);
		_audioAvailable = YES;
	}
	
	if (_rollSoundOn) {
		AudioServicesPlaySystemSound(_rollAudioID);
	}
	
	int selected = 0;
	for (int i = 0; i < DICE_COUNT; i++) {
		DieButton *dieButton = _dieButtons[i];
		if (dieButton.selected) {
			selected++;
		}
	}
	
	if (selected == DICE_COUNT) {
		return;
	}
	
	_rollButton.enabled = NO;
	_scoreButton.enabled = NO;
	
	_dieAnimationCounter = 0;
	_gameModel.currentRoll++;
	
	_currentDieAnimationCount = 0;
	for (int i = 0; i < DICE_COUNT; i++) {
		DieButton *dieButton = _dieButtons[i];
		if (!dieButton.selected) {
			_currentDieAnimationCount++;
		}
	}
	
	// For each die
	for (int i = 0; i < DICE_COUNT; i++) {
		DieButton *dieButton = _dieButtons[i];
		
		if (!dieButton.enabled) {
			dieButton.enabled = YES;
		}
		
		// Skip if it is selected
		if (dieButton.selected) {
			continue;
		}
		
		// Set to random value
		int roll = rand()%6 + 1;
		[_gameModel setDieValue:i value:roll];
		dieButton.enabled = NO;
		[dieButton setDieValue:roll animated:YES];
	}
}

/**
 * When the user presses the score button, show the ScoreViewController with the current dice
 * and suggestions.
 */
- (IBAction)viewScore
{
	ScoreViewController *scoreViewController = [[ScoreViewController alloc] initWithNibName:@"ScoreViewController" bundle:nil];
    scoreViewController.delegate = self;
    scoreViewController.viewMode = [_gameUIState getViewModeForPlayer:_gameModel.currentPlayer];
	
	scoreViewController.diceRoll = _gameModel.diceRoll;
	scoreViewController.scoreModel = [_gameModel getPlayerScore:-1];
	
	[self loadStatistics];
	[_statistics calculateScoreSuggestionsForDiceRoll:_gameModel.diceRoll];
	if (!_suggestionsOn) {
		scoreViewController.scoreSuggestions = nil;
	}
	else {
		scoreViewController.scoreSuggestions = _statistics.scoreSuggestions;
	}
	
	[self presentModalViewController:scoreViewController animated:YES];
}

/**
 * When the user changes view mode in the ScoreViewController, save it to the gameUIState
 */
- (void)changeViewMode:(ScoreViewMode)mode {
	[_gameUIState setViewMode:mode forPlayer:_gameModel.currentPlayer];
}

- (void)saveScoreForIndex:(int)index {
	int score = [ScoreModel getScoreWithIndex:index forDiceRoll:_gameModel.diceRoll];
	[[_gameModel getPlayerScore:-1] setScore:score forIndex:index];
	
	_gameModel.currentPlayer = (_gameModel.currentPlayer + 1) % _gameModel.nPlayers;
	_gameModel.currentRoll = 0;
	
	for (int i = 0; i < DICE_COUNT; i++) {
		[_gameModel setDieValue:i value:0];
		DieButton *dieButton = _dieButtons[i];
		[_gameUIState setSelectedState:NO forDie:i];
		[dieButton setDieValue:0 animated:NO];
	}
	
	if (_gameModel.nPlayers > 1) {
		[self showCurrentPlayerMessage];
	}
	
	NSLog(@"loaded...");
	ScoreModel *scoreModel = [_gameModel getPlayerScore:0];
	for (int i = 0; i < 13; i++) {
		NSLog(@"%d: %d", i, [scoreModel getScoreWithIndex:i]);
	}
	
	if (_gameModel.isEndOfGame) {
		[GameViewController removeStateFiles];
		
		FinalScoreViewController *finalScoreViewController = 
			[[FinalScoreViewController alloc] initWithNibName:@"FinalScoreViewController" bundle:nil];
		finalScoreViewController.title = NSLocalizedString(@"GAME_FINAL_SCORES", @"Final Scores");
		finalScoreViewController.gameModel = _gameModel;
		
		UINavigationController *navController = self.navigationController;
		[navController popViewControllerAnimated:NO];
		[navController pushViewController:finalScoreViewController animated:NO];
		
		
		Highscores *highscores = [Highscores loadHighscores];
		for (int i = 0; i < _gameModel.nPlayers; i++) {
			[highscores addHighScore:[_gameModel getPlayerScore:i] forPlayer:[_gameModel getPlayerName:i]];
		}
		[Highscores saveHighscores:highscores];
	}
	else {
		[self updateUI];
	}
}

/**
 * Select a dice if it is clicked.
 */
- (IBAction)diceClick:(id)sender {
	DieButton *dieButton = (DieButton *)sender;
	dieButton.selected = !dieButton.selected;
	[_gameUIState setSelectedState:dieButton.selected forDie:dieButton.tag];
}

#pragma mark Animation

/**
 * This part is animation code for showing and hiding the info messages.
 */

- (void)showCurrentPlayerMessage
{
	_messageLabel.text = [_gameModel getPlayerName:-1];
    
    [UIView animateWithDuration:0.1 delay:0.5 options:0 animations:^{
        _messageLabel.alpha = 0.6;
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.4 delay:0.75 options:0 animations:^{
            _messageLabel.alpha = 0;
        } completion:NULL];
    }];
}

//- (void)toggleCameraMessage:(BOOL)show {
//	[UIView beginAnimations:@"showCameraMessage" context:nil];
//	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
//	[UIView setAnimationDelegate:self];
//	[UIView setAnimationDuration:0.1];
//	if (show) {
//		cameraMessageLabel.alpha = 0.75;
//		cameraActivityView.alpha = 0.9;
//	}
//	else {
//		cameraMessageLabel.alpha = 0;
//		cameraActivityView.alpha = 0;
//	}
//	[UIView commitAnimations];
//}

- (void)dieButtonAnimationCompleted:(id)sender {
	_dieAnimationCounter++;
	if (_dieAnimationCounter == _currentDieAnimationCount) {
		[self updateUI];
	}
}

#pragma mark Picture Control

/**
 * When the user clicks the camera icon, show the camera interface.
 */
//- (void)loadPicture {
//	
//	rollButton.enabled = NO;
//	scoreButton.enabled = NO;
//	for (int i = 0; i < DICE_COUNT; i++) {
//		DieButton *dieButton = [dieButtons objectAtIndex:i];
//		dieButton.enabled = NO;
//	}
//	
//	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
//	imagePicker.delegate = self;
//	@try {
//		imagePicker.sourceType = recognitionSourceType;
//		[self presentModalViewController:imagePicker animated:YES];
//	}
//	@catch (NSException *e) {
//		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GAME_NO_CAMERA_TITLE", @"No Camera")
//			message:NSLocalizedString(@"GAME_NO_CAMERA_MESSAGE", @"There is currently no camera present for taking an image.")
//			delegate:nil cancelButtonTitle:NSLocalizedString(@"GAME_NO_CAMERA_OK", @"OK") otherButtonTitles:nil];
//		[alert show];
//		[alert release];
//	}
//	[imagePicker release];
//}

/**
 * After making a picture start detection in a background thread.
 */
//- (void)imagePickerController:(UIImagePickerController *)picker 
//didFinishPickingMediaWithInfo:(NSDictionary *)info {
//	
//	UIImage *image = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
//	[image retain];
//	
//	[self dismissModalViewControllerAnimated:YES];
//	[self toggleCameraMessage:YES];
//	
//	if (NO)
//	{
//		[self performSelector:@selector(testDiceRecognitionForImage:) withObject:image afterDelay:1];
//	}
//	else {
//		//[self testDiceRecognitionForImage:image];
//		
//		// Disable buttons
//		self.navigationItem.rightBarButtonItem.enabled = NO;
//		scoreButton.enabled = NO;
//		rollButton.enabled = NO;
//		
//		// Run dice detection in a background thread
//		[self performSelectorInBackground:@selector(startDiceRecognitionForImage:) withObject:image];
//	}
//}
//
//- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
//	[self dismissModalViewControllerAnimated:YES];
//	[self updateUI];
//}

/**
 * Begin dice recognition after the user made a picture.
 */
//- (void)startDiceRecognitionForImage:(UIImage *)image {
//	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//	
//	diceRecognitionResult = [DiceScanner scanDiceRollImage:image];
//	[image release];
//	
//	[self performSelectorOnMainThread:@selector(completeDiceRecognition)
//		withObject:nil waitUntilDone:NO];
//	
//	[pool release];
//}

/**
 * Method used for testing purposes.
 */
//- (void)testDiceRecognitionForImage:(UIImage *)image {
//	UIImage *test = [DiceScanner scanDiceRollImageTest:image];
//	
//	ImageViewController *imageViewController = [[ImageViewController alloc] initWithImage:test];
//	[self.navigationController pushViewController:imageViewController animated:NO];
//	
//	[imageViewController release];
//	[image release];
//	
//	[self toggleCameraMessage:NO];
//}

/**
 * After finishing dice recognition, set the die values to the detected ones.
 */
//- (void)completeDiceRecognition
//{
//	// Check if this is still the active viewController, otherwise simply do nothing
//	if (!self.navigationController || self.navigationController.visibleViewController != self) {
//		return;
//	}
//	
//	[self toggleCameraMessage:NO];
//	
//	self.navigationItem.rightBarButtonItem.enabled = YES;
//	scoreButton.enabled = YES;
//	rollButton.enabled = (_gameModel.currentRoll < 3);
//	
//	BOOL allRecognized = YES;
//	for (int i = 0; i < DICE_COUNT; i++) {
//		if (diceRecognitionResult.dice[i] == 0) {
//			allRecognized = NO;
//			break;
//		}
//	}
//	
//	if (!allRecognized) {
//		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GAME_ERROR_RECOGNITION_TITLE", @"Error Recognition") 
//			message:NSLocalizedString(@"GAME_ERROR_RECOGNITION_MESSAGE", @"Not all dice have been found during the recognition, "
//					 "please try again using 5 dice.")
//			delegate:nil cancelButtonTitle:NSLocalizedString(@"GAME_ERROR_RECOGNITION_OK", @"OK") otherButtonTitles:nil];
//		[alert show];
//		[alert release];
//	}
//	else {
//		for (int i = 0; i < DICE_COUNT; i++) {
//			[[dieButtons objectAtIndex:i] setDieValue:diceRecognitionResult.dice[i] animated:NO];
//		}
//		
//		[_gameModel setDiceRoll:diceRecognitionResult];
//		_gameModel.currentRoll = 3;
//		
//		[self updateUI];
//	}
//
//}

#pragma mark Statistics

/**
 * Load the GameStatistics class, using current score model for the current user.
 */
- (void)loadStatistics {
	if (_statistics == nil) {
		_statistics = [[GameStatistics alloc] init];
	}
	[_statistics calculateStrategyForScoreModel:[_gameModel getPlayerScore:-1]];
}

/**
 * Calculate the game strategy after rolling the dice.
 */
- (void)calculateGameStrategy {
	[self loadStatistics];
	
	_keepSuggestions = nil;
	
	if (_gameModel.currentRoll == 1 || _gameModel.currentRoll == 2) {
		[_statistics calculateKeepSuggestionsForDiceRoll:_gameModel.diceRoll
											withCurrent:_gameModel.currentRoll];
		_keepSuggestions = _statistics.keepSuggestions;
	}
	
	[_suggestionView reloadData];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	if (_keepSuggestions == nil || !_suggestionsOn) {
		return 0;
	}
	
	int count = [_keepSuggestions count];
	if (count > 3) {
		return 3;
	}
	return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (_keepSuggestions == nil || !_suggestionsOn) {
		return nil;
	}
	return NSLocalizedString(@"GAME_KEEP_SUGGESTIONS", @"Suggestions");
}

/**
 * Shows the suggestions to the user, using die pictures.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:@"cell"];
		
		CGRect cellBounds = cell.contentView.bounds;
		for (int i = 0; i < DICE_COUNT; i++) {
			int size = cellBounds.size.height;
			
			CGRect frame = CGRectMake(75 + (size + 4) * i, 0, size, size);
			UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
			imageView.tag = i + 1;
			imageView.contentMode = UIViewContentModeCenter;
			[cell.contentView addSubview:imageView];
		}
	}
	
	cell.textLabel.text = nil;
	for (int i = 0; i < DICE_COUNT; i++) {
		UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:i + 1];
		imageView.image = nil;
		imageView.highlightedImage = nil;
	}
	
	// Three kinds of suggestions exist. Either keep a certain amount of dice, re-roll all the dice,
	// or save the current score (keep all dice).
	if (_keepSuggestions != nil) {
		KeepSuggestion *suggestion = _keepSuggestions[indexPath.row];
		WidgetState keepState = suggestion.keepState;
		
		int counter = 0;
		for (int i = 0; i < MAX_DIE_VALUE; i++) {
			counter += keepState.values[i];
		}
		
		if (counter > 0 && counter < DICE_COUNT) {
			int imageIndex = 1;
			for (int i = 0; i < MAX_DIE_VALUE; i++) {
				while (keepState.values[i] > 0) {
					UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:imageIndex];
					imageView.image = _keepImagesNormal[i];
					imageView.highlightedImage = _keepImagesHighlighted[i];
					
					imageIndex++;
					keepState.values[i]--;
				}
			}
			
			cell.textLabel.text = [NSLocalizedString(@"GAME_KEEP", @"Keep") stringByAppendingString:@":"];
		}
		else if (counter == 0)  {
			cell.textLabel.text = NSLocalizedString(@"GAME_REROLL_ALL", @"Re-roll all dice");
		}
		else {
			cell.textLabel.text = NSLocalizedString(@"GAME_SAVE_SCORE", @"Save score");
		}
	}
	
	for (int i = 0; i < DICE_COUNT; i++) {
		UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:i + 1];
		if (imageView.image != nil) {
			[cell.contentView bringSubviewToFront:imageView];
		}
	}
	
	return cell;
}

/**
 * Makes sure if a user clicks on a suggestion, the right dice are selected.
 */
- (NSIndexPath *)tableView:(UITableView *)tableView 
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	KeepSuggestion *suggestion = _keepSuggestions[indexPath.row];
	WidgetState keepState = suggestion.keepState;
	
	int counter = 0;
	for (int i = 0; i < MAX_DIE_VALUE; i++) {
		counter += keepState.values[i];
	}
	
	if (counter == DICE_COUNT) {
		[self viewScore];
	}
	else {
		for (int i = 0; i < DICE_COUNT; i++) {
			DieButton *dieButton = _dieButtons[i];
			int dieValue = _gameModel.diceRoll.dice[i];
			
			if (keepState.values[dieValue - 1] > 0) {
				dieButton.selected = YES;
				keepState.values[dieValue - 1]--;
			}
			else {
				dieButton.selected = NO;
			}
			[_gameUIState setSelectedState:dieButton.selected forDie:dieButton.tag];
		}
	}
	
	return nil;
}

#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
	AudioServicesDisposeSystemSoundID(_shakeAudioID);
	AudioServicesDisposeSystemSoundID(_rollAudioID);
	_audioAvailable = NO;
	
	_statistics = nil;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
	AudioServicesDisposeSystemSoundID(_shakeAudioID);
	AudioServicesDisposeSystemSoundID(_rollAudioID);
}

@end
