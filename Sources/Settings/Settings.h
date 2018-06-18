//
//  Settings.h
//  iRoll
//
//  Created by Steven Roebert on 17/04/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//

@interface Settings : NSObject <NSCoding>

+ (NSString *)settingsFilePath;
+ (BOOL)settingsExists;
+ (Settings *)loadSettings;
+ (void)saveSettings:(Settings *)settings;

- (void)setDefaults;

- (id)getValueForKey:(id)key;
- (void)setValue:(id)value forKey:(id)key;

@end
