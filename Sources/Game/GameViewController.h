//
//  GameViewController.h
//  iRoll
//
//  Created by Steven Roebert on 15/02/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//
//	View for each players turn where the player can roll dice, select dice to keep and go to
//	the score view.
//

#import "GameModel.h"
#import "DieButton.h"
#import "ScoreViewController.h"

@interface GameViewController : UIViewController </*UINavigationControllerDelegate, 
	UIImagePickerControllerDelegate,*/ ScoreViewControllerDelegate, DieButtonDelegate,
	UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView *suggestionView;
@property (nonatomic, strong) IBOutlet UIButton *dieButton1, *dieButton2, 
	*dieButton3, *dieButton4, *dieButton5;
@property (nonatomic, strong) IBOutlet UIButton *rollButton, *scoreButton;
@property (nonatomic, strong) IBOutlet UILabel *playerLabel, *rollLabel, *messageLabel, *cameraMessageLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *cameraActivityView;
@property (nonatomic, strong) GameModel *gameModel;

+ (NSString *)stateFilePath;
+ (NSString *)uiStateFilePath;
+ (BOOL)stateFileExists;
+ (BOOL)uiStateFileExists;
+ (void)removeStateFiles;

- (void)saveState;
- (BOOL)restoreState;

- (void)resetShake;
- (void)shakingDice;

- (void)updateUI;
- (IBAction)rollDice;
- (IBAction)viewScore;
- (IBAction)diceClick:(id)sender;

- (void)showCurrentPlayerMessage;
//- (void)toggleCameraMessage:(BOOL)show;

//- (void)loadPicture;
//- (void)startDiceRecognitionForImage:(UIImage *)image;
//- (void)testDiceRecognitionForImage:(UIImage *)image;
//- (void)completeDiceRecognition;

- (void)loadStatistics;
- (void)calculateGameStrategy;

@end
