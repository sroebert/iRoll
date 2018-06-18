//
//  NewGameViewController.h
//  iRoll
//
//  Created by Steven Roebert on 27/02/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//
//	Controller for setting up a new game. The user can select the number of players and optionally
//	add names for each player.
//

@protocol NewGameViewControllerDelegate <NSObject>

@optional

- (void)startNewGameWithPlayers:(int)nPlayers andNames:(NSArray *)names;

@end

@interface NewGameViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UINavigationItem *navItem;
@property (nonatomic, strong) IBOutlet UITextField *textField1, *textField2, *textField3,
	*textField4, *textField5, *textField6, *textField7, *textField8;
@property (nonatomic, strong) IBOutlet UIPickerView *pickerView;
@property (nonatomic, weak) id <NewGameViewControllerDelegate> delegate;

- (void)cancelClick;
- (void)startClick;

@end
