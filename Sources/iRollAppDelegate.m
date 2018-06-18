//
//  iRollAppDelegate.m
//  iRoll
//
//  Created by Steven Roebert on 15/02/2010.
//  Copyright Steven Roebert 2010. All rights reserved.
//

#import "iRollAppDelegate.h"
#import "GameViewController.h"
#import "AWIntrospectorGadget.h"

@implementation iRollAppDelegate {
	UIViewController *_currentViewController;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    _window.frame = [[UIScreen mainScreen] bounds];
    _window.rootViewController = _navController;
    [_window makeKeyAndVisible];
    
    [AWIntrospectorGadget sharedIntrospector].enabled = YES;
}

- (void)navigationController:(UINavigationController *)navigationController
	  willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	
	// Make sure the game state is saved when the user returns back to the main menu
	if (_currentViewController != nil && 
		[_currentViewController isMemberOfClass:[GameViewController class]])
	{
		GameViewController *gameViewController = (GameViewController *)_currentViewController;
		[gameViewController saveState];
	}
}

- (void)navigationController:(UINavigationController *)navigationController
	   didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	_currentViewController = navigationController.topViewController;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	
	// Make sure the game state is saved when the application quits
	if (_currentViewController != nil && 
		[_currentViewController isMemberOfClass:[GameViewController class]])
	{
		GameViewController *gameViewController = (GameViewController *)_currentViewController;
		[gameViewController saveState];
	}
}

- (void)applicationWillTerminate:(UIApplication *)application {
	
	// Make sure the game state is saved when the application quits
	if (_currentViewController != nil && 
		[_currentViewController isMemberOfClass:[GameViewController class]])
	{
		GameViewController *gameViewController = (GameViewController *)_currentViewController;
		[gameViewController saveState];
	}
}



@end
