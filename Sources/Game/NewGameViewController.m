//
//  NewGameViewController.m
//  iRoll
//
//  Created by Steven Roebert on 27/02/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//

#import "NewGameViewController.h"

@interface NewGameViewController () {
    int _nPlayers;
	NSArray *_textFields;
}

- (void)updateTextFields:(BOOL)loadNames;

@end


@implementation NewGameViewController

#pragma mark Init

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Hide all text fields but one
	_textFields = [[NSArray alloc] initWithObjects:_textField1, _textField2, _textField3, _textField4,
				  _textField5, _textField6, _textField7, _textField8, nil];
	for (int i = 1; i < 8; i++) {
		UITextField *textField = (UITextField *)_textFields[i];
		textField.enabled = NO;
		textField.text = nil;
		textField.alpha = 0;
	}
	
	_nPlayers = [[NSUserDefaults standardUserDefaults] integerForKey:@"defaultNumberOfPlayers"];
	if (_nPlayers == 0) {
		_nPlayers = 1;
	}
	
	_navItem.title = NSLocalizedString(@"NEW_GAME_TITLE", @"New Game");
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"NEW_GAME_CANCEL_BUTTON", @"Cancel") 
																	 style:UIBarButtonItemStyleBordered 
																	target:self action:@selector(cancelClick)];
	_navItem.leftBarButtonItem = cancelButton;
	
	UIBarButtonItem *startButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"NEW_GAME_START_BUTTON", @"Start") 
																	 style:UIBarButtonItemStyleBordered 
																	target:self action:@selector(startClick)];
	_navItem.rightBarButtonItem = startButton;
	
	[self updateTextFields:YES];
	[_pickerView selectRow:_nPlayers - 1 inComponent:0 animated:NO];
}

- (void)updateTextFields:(BOOL)loadNames
{
	// Enable the text fields for each player, based on the number of players
	for (int i = 0; i < _nPlayers; i++) {
		UITextField *textField = (UITextField *)_textFields[i];
		textField.enabled = YES;
		textField.alpha = 1;
		
		if (loadNames) {
			textField.text = [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"playerName%02d", i]];
		}
	}
	
	// Disable all other text fields
	for (int i = _nPlayers; i < 8; i++) {
		UITextField *textField = (UITextField *)_textFields[i];
		textField.enabled = NO;
		textField.alpha = 0;
		
		if (loadNames) {
			textField.text = [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"playerName%02d", i]];
		}
	}
}

#pragma mark UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return 8;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row
			forComponent:(NSInteger)component {
	if (row == 0) {
		return [@"1 " stringByAppendingString:NSLocalizedString(@"NEW_GAME_PLAYER", @"Player")];
	}
	return [NSString stringWithFormat:@"%d %@", row + 1, NSLocalizedString(@"NEW_GAME_PLAYERS", @"Players")];
}

#pragma mark User Actions

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
	   inComponent:(NSInteger)component {
	
	_nPlayers = row + 1;
	[[NSUserDefaults standardUserDefaults] setInteger:_nPlayers forKey:@"defaultNumberOfPlayers"];
	[self updateTextFields:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void)cancelClick {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)startClick {
	if ([_delegate respondsToSelector:@selector(startNewGameWithPlayers:andNames:)]) {
		
		// Get all player names, make empty string if nil
		NSMutableArray *names = [NSMutableArray arrayWithCapacity:_nPlayers];
		for (int i = 0; i < _nPlayers; i++) {
			UITextField *textField = (UITextField *)_textFields[i];
			NSString *name = textField.text;
			if (name == nil) {
				name = @"";
			}
			
			[names addObject:name];
			[[NSUserDefaults standardUserDefaults] setObject:name forKey:[NSString stringWithFormat:@"playerName%02d", i]];
		}
		
		// Call delegate method to start new game
		[_delegate startNewGameWithPlayers:_nPlayers andNames:names];
	}
	[self dismissModalViewControllerAnimated:YES];
}

@end
