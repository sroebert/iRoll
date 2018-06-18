//
//  ScoreViewController.h
//  iRoll
//
//  Created by Steven Roebert on 19/02/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//
//	ViewController for showing the current score to the user. It is also used for the user to
//	select a category to use for the current dice roll.
//

#import <QuartzCore/QuartzCore.h>
#import "DieButton.h"
#import "ScoreModel.h"

typedef enum {
	ScoreViewModeDefault = 0,
	ScoreViewModeSuggested
} ScoreViewMode;

@protocol ScoreViewControllerDelegate <NSObject>

@optional

- (void)cancelSaveScore;
- (void)changeViewMode:(ScoreViewMode)mode;

@required

- (void)saveScoreForIndex:(int)index;

@end

@interface ScoreViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet DieButton *diceButton1, *diceButton2, 
	*diceButton3, *diceButton4, *diceButton5;
@property (nonatomic, strong) IBOutlet UITableView *scoreView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *viewModeControl;
@property (nonatomic, strong) IBOutlet UINavigationBar *navBar;
@property (nonatomic, weak) id <ScoreViewControllerDelegate> delegate;
@property (nonatomic, assign) DiceRoll diceRoll;
@property (nonatomic, strong) ScoreModel *scoreModel;
@property (nonatomic, assign) ScoreViewMode viewMode;
@property (nonatomic, copy) NSArray *scoreSuggestions;

- (IBAction)saveButtonClick;
- (IBAction)cancelButtonClick;
- (IBAction)viewModeClick;
- (int)getScoreIndexForIndexPath:(NSIndexPath *)indexPath;

@end
