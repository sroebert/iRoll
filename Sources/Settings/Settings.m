//
//  Settings.m
//  iRoll
//
//  Created by Steven Roebert on 17/04/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//

#import "Settings.h"


@implementation Settings {
    NSMutableDictionary *_settingValues;
}

#pragma mark Load/Save

+ (NSString *)settingsFilePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = paths[0];
	NSString *settingsFilePath = [documentsPath stringByAppendingPathComponent:@"settings.data"];
	return settingsFilePath;
}

+ (BOOL)settingsExists {
	return [[NSFileManager defaultManager] fileExistsAtPath:[Settings settingsFilePath]];
}

+ (void)removeHighscores {
	if ([Settings settingsExists]) {
		[[NSFileManager defaultManager] removeItemAtPath:[Settings settingsFilePath] error:nil];
	}
}

+ (Settings *)loadSettings
{
	Settings *settings = nil;
	
	// Try to restore settings from disk
	@try {
		settings = [NSKeyedUnarchiver 
					  unarchiveObjectWithFile:[Settings settingsFilePath]];
	}
	@catch (NSException * e) {
		if (![e.name isEqualToString:@"NSInvalidArgumentException"]) {
			@throw e;
		}
	}
	
	if (settings == nil) {
		settings = [[Settings alloc] init];
	}
	return settings;
}

+ (void)saveSettings:(Settings *)settings
{
	[NSKeyedArchiver archiveRootObject:settings toFile:[Settings settingsFilePath]];
}

#pragma mark Init

- (id)init
{
	if ((self = [super init])) {
		_settingValues = [[NSMutableDictionary alloc] init];
		[self setDefaults];
	}
	return self;
}

- (void)setDefaults
{
	[self setValue:@YES forKey:@"ShowSuggestions"];
	[self setValue:@YES forKey:@"ShakeToRoll"];
	[self setValue:@YES forKey:@"VibrateWhenShake"];
	
	[self setValue:@YES forKey:@"RollSound"];
	[self setValue:@YES forKey:@"ShakeSound"];
}

#pragma mark Get/Set

- (id)getValueForKey:(id)key
{
	return _settingValues[key];
}

- (void)setValue:(id)value forKey:(id)key
{
	_settingValues[key] = value;
}

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:_settingValues forKey:@"settingValues"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super init])) {
		_settingValues = [aDecoder decodeObjectForKey:@"settingValues"];
	}
	return self;
}

@end
