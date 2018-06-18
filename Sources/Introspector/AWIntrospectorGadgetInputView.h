//
//  AWIntrospectorGadgetInputView.h
//  AWFoundation
//
//  Created by Steven Roebert on 19-11-2013.
//  Copyright (c) 2013 Steven Roebert. All rights reserved.
//

#if defined(DEBUG)

@protocol AWIntrospectorGadgetInputViewDelegate;

extern NSString *const AWIntrospectorKeyInputUpArrow;
extern NSString *const AWIntrospectorKeyInputDownArrow;
extern NSString *const AWIntrospectorKeyInputLeftArrow;
extern NSString *const AWIntrospectorKeyInputRightArrow;

@interface AWIntrospectorGadgetKeyboardCommand : NSObject

@property (nonatomic, copy) NSString *input;
@property (nonatomic, assign) UIKeyModifierFlags modifierFlags;

@end

@interface AWIntrospectorGadgetInputView : UIView

@property (nonatomic, copy) NSArray *supportedKeyboardCommands;

@property (nonatomic, weak) id <AWIntrospectorGadgetInputViewDelegate> delegate;

@end

@protocol AWIntrospectorGadgetInputViewDelegate <NSObject>
@optional

- (void)introspectorGadgetInputView:(AWIntrospectorGadgetInputView *)view didPerformKeyCommand:(AWIntrospectorGadgetKeyboardCommand *)command;

@end

#endif
