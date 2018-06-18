//
//  SettingsViewController.h
//  iRoll
//
//  Created by Steven Roebert on 17/04/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UINavigationItem *navItem;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

- (NSString *)getCellIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)switchValueChanged:(id)sender;

@end
