//
//  AWKeyboardHelper.h
//  AWFoundation
//
//  Created by Steven Roebert on 04-08-2013.
//  Copyright (c) 2013 Steven Roebert. All rights reserved.
//

@interface AWKeyboardHelper : NSObject

+ (instancetype)sharedHelper;
+ (instancetype)alloc __attribute__((unavailable("this class is a singleton")));
- (instancetype)init __attribute__((unavailable("this class is a singleton")));
+ (instancetype)new __attribute__((unavailable("this class is a singleton")));

@property (nonatomic, readonly, getter = isKeyboardVisible) BOOL keyboardVisible;
- (CGRect)keyboardFrameInView:(UIView *)view;

@end

@protocol AWKeyboardObserver
@optional

- (void)keyboardWillShowToFrame:(CGRect)frame;
- (void)keyboardAnimateShowFromFrame:(CGRect)fromFrame toFrame:(CGRect)frame;
- (void)keyboardDidShowFromFrame:(CGRect)frame;

- (void)keyboardWillHideToFrame:(CGRect)frame;
- (void)keyboardAnimateHideFromFrame:(CGRect)fromFrame toFrame:(CGRect)frame;
- (void)keyboardDidHideFromFrame:(CGRect)frame;

- (void)keyboardWillChangeToFrame:(CGRect)toFrame;
- (void)keyboardAnimateFromFrame:(CGRect)fromFrame toFrame:(CGRect)frame;
- (void)keyboardDidChangeFromFrame:(CGRect)fromFrame;

@end
