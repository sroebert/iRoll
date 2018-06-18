//
//  MainMenuController.h
//  iRoll
//
//  Created by Steven Roebert on 15/02/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//
//  This class shows holds the main menu and performs the appropriate action when a menu
//  item is clicked.
//

#import <UIKit/UIKit.h>
#import "GameViewController.h"
#import "NewGameViewController.h"

@interface MainMenuController : UIViewController <UITableViewDelegate, UITableViewDataSource, 
	UIActionSheetDelegate, NewGameViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UITableView *mainMenu;

- (GameViewController *)newGameViewController;
- (void)setupNewGame;

@end
