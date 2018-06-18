//
//  AWGCDTimer.m
//  AWFoundation
//
//  Created by Steven Roebert on 28-07-2013.
//  Copyright (c) 2013 Steven Roebert. All rights reserved.
//

#import "AWGCDTimer.h"

@implementation AWGCDTimer {
    dispatch_source_t _timer;
}

#pragma mark -
#pragma mark Initialize

+ (instancetype)timerWithTimeInterval:(NSTimeInterval)seconds {
	return [self timerWithTimeInterval:seconds repeats:NO];
}

+ (instancetype)timerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats {
	return [[[self class] alloc] initWithTimeInterval:seconds repeats:repeats];
}

- (instancetype)initWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats {
	if ((self = [super init])) {
		_timeInterval = seconds;
		_repeats = repeats;
	}
	return self;
}

#pragma mark -
#pragma mark Queue

- (dispatch_queue_t)timerQueue {
    if (_queue) {
        return _queue;
    }
    return dispatch_get_main_queue();
}

#pragma mark -
#pragma mark Timer

- (void)cancel {
	if (_timer) {
		dispatch_source_cancel(_timer);
		_timer = NULL;
	}
}

- (BOOL)isRunning {
	return _timer != NULL;
}

- (void)updateTimer {
	dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, _timeInterval * NSEC_PER_SEC), _timeInterval * 1000000000, 0);
}

- (void)setTimeInterval:(NSTimeInterval)timeInterval {
	if (_timeInterval == timeInterval) {
		return;
	}
	
	_timeInterval = timeInterval;
	dispatch_async([self timerQueue], ^{
		[self updateTimer];
	});
}

- (void)run:(void(^)(AWGCDTimer *timer))completion {
	[self cancel];
	_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, [self timerQueue]);
	
	[self updateTimer];
	
	dispatch_source_set_event_handler(_timer, ^{
		
		if (completion) {
			completion(self);
		}
		
		if (!_repeats) {
			[self cancel];
		}
	});
	dispatch_resume(_timer);
}

@end
