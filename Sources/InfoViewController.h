//
//  RulesViewController.h
//  iRoll
//
//  Created by Steven Roebert on 27/02/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//
//	This class is used to show simple html text. It is used for showing the about page and 
//	the iRoll rules.
//

@interface InfoViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIWebView *webView;

- (id)initWithText:(NSString *)text;

@end
