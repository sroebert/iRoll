//
//  AWGCDTimer.h
//  AWFoundation
//
//  Created by Steven Roebert on 28-07-2013.
//  Copyright (c) 2013 Steven Roebert. All rights reserved.
//

@interface AWGCDTimer : NSObject

+ (instancetype)timerWithTimeInterval:(NSTimeInterval)seconds;
+ (instancetype)timerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats;
- (instancetype)initWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats;

@property (nonatomic, readonly) dispatch_queue_t queue;
@property (nonatomic, assign) NSTimeInterval timeInterval;
@property (nonatomic, assign) BOOL repeats;

@property (nonatomic, readonly, getter = isRunning) BOOL running;
- (void)run:(void(^)(AWGCDTimer *timer))completion;
- (void)cancel;

@end
