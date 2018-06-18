//
//  SettingsViewController.m
//  iRoll
//
//  Created by Steven Roebert on 17/04/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//

#import "SettingsViewController.h"
#import "Settings.h"

@implementation SettingsViewController {
    Settings *_settings;
}

#pragma mark -
#pragma mark View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		_settings = nil;
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.allowsSelection = NO;
	
	_navItem.title = NSLocalizedString(@"SETTINGS_TITLE", @"Settings iRoll");
	
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SETTINGS_DONE", @"Done") style:UIBarButtonItemStyleDone target:self action:@selector(doneClicked)];
	_navItem.rightBarButtonItem = doneButton;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	_settings = [Settings loadSettings];
	[_tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[Settings saveSettings:_settings];
	
	[_tableView flashScrollIndicators];
}

- (void)doneClicked
{
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section)
	{
		case 0:
			return NSLocalizedString(@"SETTINGS_SECTION_GENERAL", @"General");
			
		case 1:
			return NSLocalizedString(@"SETTINGS_SECTION_SOUNDS", @"Sounds");
	}
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section)
	{
		// General
		case 0:
			return 3;
		
		// Sounds
		case 1:
			return 2;
	}
	return 0;
}

- (NSString *)getCellIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return @"boolSetting";
}

- (UITableViewCell *)tableView:(UITableView *)tableview cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *identifier = [self getCellIdentifierForRowAtIndexPath:indexPath];
	
	UISwitch *uiSwitch;
	
	UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
			reuseIdentifier:identifier];
		
		if ([identifier isEqual:@"boolSetting"])
		{	
			uiSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
			[uiSwitch addTarget:self action:@selector(switchValueChanged:)
				forControlEvents:UIControlEventValueChanged];
			[cell addSubview:uiSwitch];
			cell.accessoryView = uiSwitch;
		}
	}

	switch (indexPath.section)
	{
		// General
		case 0:
			switch (indexPath.row)
			{
				case 0:
					cell.textLabel.text = NSLocalizedString(@"SETTINGS_VALUE_SHOW_SUGGESTIONS", @"Show Suggestions");
					uiSwitch = (UISwitch *)cell.accessoryView;
					uiSwitch.tag = 0;
					uiSwitch.on = [[_settings getValueForKey:@"ShowSuggestions"] boolValue];
					break;
				case 1:
					cell.textLabel.text = NSLocalizedString(@"SETTINGS_VALUE_SHAKE_TO_ROLL", @"Shake To Roll");
					uiSwitch = (UISwitch *)cell.accessoryView;
					uiSwitch.tag = 1;
					uiSwitch.on = [[_settings getValueForKey:@"ShakeToRoll"] boolValue];
					break;
				case 2:
					cell.textLabel.text = NSLocalizedString(@"SETTINGS_VALUE_VIBRATE_ON_SHAKE", @"Vibrate On Shake");
					uiSwitch = (UISwitch *)cell.accessoryView;
					uiSwitch.tag = 2;
					uiSwitch.on = [[_settings getValueForKey:@"VibrateWhenShake"] boolValue];
					break;
			}
			break;
			
		// Sounds
		case 1:
			switch (indexPath.row)
			{
				case 0:
					cell.textLabel.text = NSLocalizedString(@"SETTINGS_VALUE_ROLL_SOUND", @"Roll Sound");
					uiSwitch = (UISwitch *)cell.accessoryView;
					uiSwitch.tag = 3;
					uiSwitch.on = [[_settings getValueForKey:@"RollSound"] boolValue];
					break;
				case 1:
					cell.textLabel.text = NSLocalizedString(@"SETTINGS_VALUE_SHAKE_SOUND", @"Shake Sound");
					uiSwitch = (UISwitch *)cell.accessoryView;
					uiSwitch.tag = 4;
					uiSwitch.on = [[_settings getValueForKey:@"ShakeSound"] boolValue];
					break;
			}
			break;
	}

	return cell;
}

#pragma mark -
#pragma mark User Changes

- (void)switchValueChanged:(id)sender
{
	UISwitch *uiSwitch = (UISwitch *)sender;
	switch (uiSwitch.tag)
	{
		case 0:
			[_settings setValue:@(uiSwitch.on) forKey:@"ShowSuggestions"];
			break;
		case 1:
			[_settings setValue:@(uiSwitch.on) forKey:@"ShakeToRoll"];
			break;
		case 2:
			[_settings setValue:@(uiSwitch.on) forKey:@"VibrateWhenShake"];
			break;
		case 3:
			[_settings setValue:@(uiSwitch.on) forKey:@"RollSound"];
			break;
		case 4:
			[_settings setValue:@(uiSwitch.on) forKey:@"ShakeSound"];
			break;
	}
}

@end

