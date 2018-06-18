//
//  AWKeyboardHelper.m
//  AWFoundation
//
//  Created by Steven Roebert on 04-08-2013.
//  Copyright (c) 2013 Steven Roebert. All rights reserved.
//

#import "AWKeyboardHelper.h"

@implementation AWKeyboardHelper {
    CGRect _keyboardFrame;
    id <AWKeyboardObserver> _proxy;
}

+ (instancetype)sharedHelper {
	static id singleton = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		singleton = [(id)[super alloc] init];
	});
	return singleton;
}

#pragma mark -
#pragma mark Initialize

+ (void)load {
    @autoreleasepool {
        // Make sure the helper is started when the app launches.
        [AWKeyboardHelper sharedHelper];
    }
}

- (id)init {
	if ((self = [super init])) {
        _keyboardFrame = CGRectZero;
        _keyboardVisible = NO;
        
//        _proxy = [[AWInvocationCenter defaultCenter] proxyForProtocol:@protocol(AWKeyboardObserver) object:self usingMainQueue:NO];
        
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
	}
	return self;
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}

#pragma mark -
#pragma mark Utils

- (CGRect)keyboardFrameInView:(UIView *)view {
    return [view convertRect:_keyboardFrame fromView:nil];
}

- (UIViewAnimationOptions)animationOptionsForNotification:(NSNotification *)notification {
    UIViewAnimationCurve curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState;
    switch (curve) {
        case UIViewAnimationCurveEaseIn:
            options |= UIViewAnimationOptionCurveEaseIn;
            break;
        case UIViewAnimationCurveEaseOut:
            options |= UIViewAnimationOptionCurveEaseOut;
            break;
        case UIViewAnimationCurveEaseInOut:
            options |= UIViewAnimationOptionCurveEaseInOut;
            break;
        case UIViewAnimationCurveLinear:
            options |= UIViewAnimationOptionCurveLinear;
            break;
    }
    return options;
}

#pragma mark -
#pragma mark Notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    
//    CGRect fromFrame = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect toFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    _keyboardVisible = YES;
    _keyboardFrame = toFrame;
//    [_proxy keyboardWillShowToFrame:toFrame];
    
//    UIViewAnimationOptions options = [self animationOptionsForNotification:notification];
//    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
//    [UIView animateWithDuration:duration delay:0 options:options animations:^{
//        [_proxy keyboardAnimateShowFromFrame:fromFrame toFrame:toFrame];
//    } completion:NULL];
}

- (void)keyboardDidShow:(NSNotification *)notification {
//    CGRect fromFrame = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
//    [_proxy keyboardDidShowFromFrame:fromFrame];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
//    CGRect fromFrame = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect toFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    _keyboardFrame = toFrame;
//    [_proxy keyboardWillHideToFrame:toFrame];
    
//    UIViewAnimationOptions options = [self animationOptionsForNotification:notification];
//    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
//    [UIView animateWithDuration:duration delay:0 options:options animations:^{
//        [_proxy keyboardAnimateHideFromFrame:fromFrame toFrame:toFrame];
//    } completion:NULL];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    _keyboardVisible = NO;
    
//    CGRect fromFrame = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
//    [_proxy keyboardDidHideFromFrame:fromFrame];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    
//    CGRect fromFrame = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect toFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    _keyboardFrame = toFrame;
//    [_proxy keyboardWillChangeToFrame:toFrame];
    
//    UIViewAnimationOptions options = [self animationOptionsForNotification:notification];
//    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
//    [UIView animateWithDuration:duration delay:0 options:options animations:^{
//        [_proxy keyboardAnimateFromFrame:fromFrame toFrame:toFrame];
//    } completion:NULL];
}

- (void)keyboardDidChangeFrame:(NSNotification *)notification {
//    CGRect fromFrame = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
//    [_proxy keyboardDidChangeFromFrame:fromFrame];
}

@end
