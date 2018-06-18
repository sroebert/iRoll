//
//  iRollAppDelegate.h
//  iRoll
//
//  Created by Steven Roebert on 15/02/2010.
//  Copyright Steven Roebert 2010. All rights reserved.
//
//  The main AppDelegate, starting the application and saving the game state when quiting.
//

@interface iRollAppDelegate : NSObject <UIApplicationDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UINavigationController *navController;

@end

