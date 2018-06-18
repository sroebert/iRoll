//
//  WidgetData.m
//  iRoll
//
//  Created by Steven Roebert on 17/03/2010.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "WidgetData.h"


@implementation WidgetData {
    WidgetDataStruct _data;
}

- (WidgetDataStruct *)data {
	return &_data;
}

/**
 * Save the data to file. Simply by saving the struct directly as binary data to disk.
 */
- (BOOL)saveToFile:(NSString *)path {
	BOOL succeed = YES;
	NSData *nsData = [[NSData alloc] initWithBytesNoCopy:&_data 
		length:sizeof(WidgetDataStruct) freeWhenDone:NO];
	@try {
		[nsData writeToFile:path atomically:NO];
	}
	@catch (NSException * e) {
		succeed = NO;
	}
	@finally {
		nsData = nil;
	}
	return succeed;
}

/**
 * Load the data back from disk into the struct.
 */
- (BOOL)loadFromFile:(NSString *)path {
	BOOL succeed = YES;
	NSData *nsData = [[NSData alloc] initWithContentsOfFile:path];
	@try {
		if ([nsData length] == sizeof(WidgetDataStruct)) {
			[nsData getBytes:&_data length:sizeof(WidgetDataStruct)];
		}
		else {
			succeed = NO;
		}
	}
	@catch (NSException * e) {
		succeed = NO;
	}
	@finally {
		nsData = nil;
	}
	return succeed;
}

@end
