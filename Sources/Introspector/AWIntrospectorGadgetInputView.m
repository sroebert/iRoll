//
//  AWIntrospectorGadgetInputView.m
//  AWFoundation
//
//  Created by Steven Roebert on 19-11-2013.
//  Copyright (c) 2013 Steven Roebert. All rights reserved.
//

#if defined(DEBUG)

#import "AWIntrospectorGadgetInputView.h"
#import "AWGCDTimer.h"

NSString *const AWIntrospectorKeyInputUpArrow           = @"AWIntrospectorKeyInputUpArrow";
NSString *const AWIntrospectorKeyInputDownArrow         = @"AWIntrospectorKeyInputDownArrow";
NSString *const AWIntrospectorKeyInputLeftArrow         = @"AWIntrospectorKeyInputLeftArrow";
NSString *const AWIntrospectorKeyInputRightArrow        = @"AWIntrospectorKeyInputRightArrow";

@implementation AWIntrospectorGadgetKeyboardCommand
@end

@interface AWIntrospectorGadgetInputView () <UITextViewDelegate> {
    UITextView *_inputView;
    NSMutableArray *_keyCommands;
    AWGCDTimer *_selectionChangeTimer;
}

@end

@implementation AWIntrospectorGadgetInputView

#pragma mark -
#pragma mark Initialize

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		
        if (![UIView instancesRespondToSelector:@selector(keyCommands)]) {
            _selectionChangeTimer = [AWGCDTimer timerWithTimeInterval:0];
            
            _inputView = [[UITextView alloc] init];
            _inputView.autocorrectionType = UITextAutocorrectionTypeNo;
            _inputView.autocapitalizationType = UITextAutocapitalizationTypeNone;
            _inputView.scrollsToTop = NO;
            _inputView.inputView = [[UIView alloc] init];
            [self addSubview:_inputView];
            [self resetInputView];
        }
	}
	return self;
}

#pragma mark -
#pragma mark Layout

- (void)layoutSubviews {
    _inputView.frame = self.bounds;
}

#pragma mark -
#pragma mark Responder

- (BOOL)isFirstResponder {
    if (_inputView) {
        return [_inputView isFirstResponder];
    }
    return [super isFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
    if (_inputView) {
        return [_inputView canBecomeFirstResponder];
    }
    return YES;
}

- (BOOL)becomeFirstResponder {
    if (_inputView) {
        _inputView.delegate = nil;
        BOOL returnValue = [_inputView becomeFirstResponder];
        _inputView.delegate = self;
        return returnValue;
    }
    return [super becomeFirstResponder];
}

- (BOOL)canResignFirstResponder {
    if (_inputView) {
        return [_inputView canResignFirstResponder];
    }
    return YES;
}

- (BOOL)resignFirstResponder {
    if (_inputView) {
        return [_inputView resignFirstResponder];
    }
    return [super resignFirstResponder];
}

#pragma mark -
#pragma mark Input View

- (void)resetInputView {
    _inputView.delegate = nil;
    _inputView.text = @"\n2 4567 9\n";
	_inputView.selectedRange = NSMakeRange(5, 0);
	_inputView.delegate = self;
}

#pragma mark -
#pragma mark Key Commands

- (void)setSupportedKeyboardCommands:(NSArray *)supportedKeyboardCommands {
    _supportedKeyboardCommands = [supportedKeyboardCommands copy];
    if (![UIView instancesRespondToSelector:@selector(keyCommands)]) {
        return;
    }
    
    if (!_keyCommands) {
        _keyCommands = [NSMutableArray arrayWithCapacity:[_supportedKeyboardCommands count]];
    }
    else {
        [_keyCommands removeAllObjects];
    }
    
    [_supportedKeyboardCommands enumerateObjectsUsingBlock:^(AWIntrospectorGadgetKeyboardCommand *command, NSUInteger idx, BOOL *stop) {
        
        NSString *input = command.input;
        if ([input isEqualToString:AWIntrospectorKeyInputUpArrow]) {
            input = UIKeyInputUpArrow;
        }
        else if ([input isEqualToString:AWIntrospectorKeyInputDownArrow]) {
            input = UIKeyInputDownArrow;
        }
        else if ([input isEqualToString:AWIntrospectorKeyInputLeftArrow]) {
            input = UIKeyInputLeftArrow;
        }
        else if ([input isEqualToString:AWIntrospectorKeyInputRightArrow]) {
            input = UIKeyInputRightArrow;
        }
        
        UIKeyCommand *keyCommand = [UIKeyCommand keyCommandWithInput:input modifierFlags:command.modifierFlags action:@selector(didPerformKeyCommand:)];
        [_keyCommands addObject:keyCommand];
    }];
}

- (NSArray *)keyCommands {
    return _keyCommands;
}

- (void)didPerformKeyCommand:(UIKeyCommand *)keyCommand {
    AWIntrospectorGadgetKeyboardCommand *command = [[AWIntrospectorGadgetKeyboardCommand alloc] init];
    
    if ([keyCommand.input isEqualToString:UIKeyInputUpArrow]) {
        command.input = AWIntrospectorKeyInputUpArrow;
    }
    else if ([keyCommand.input isEqualToString:UIKeyInputDownArrow]) {
        command.input = AWIntrospectorKeyInputDownArrow;
    }
    else if ([keyCommand.input isEqualToString:UIKeyInputLeftArrow]) {
        command.input = AWIntrospectorKeyInputLeftArrow;
    }
    else if ([keyCommand.input isEqualToString:UIKeyInputRightArrow]) {
        command.input = AWIntrospectorKeyInputRightArrow;
    }
    else {
        if ((keyCommand.modifierFlags & UIKeyModifierShift) != 0) {
            command.input = [keyCommand.input uppercaseString];
        }
        else {
            command.input = keyCommand.input;
        }
    }
    
    command.modifierFlags = keyCommand.modifierFlags;
    [self didPerformIntrospectorKeyCommand:command];
}

- (void)didPerformIntrospectorKeyCommand:(AWIntrospectorGadgetKeyboardCommand *)keyCommand {
    if ([_delegate respondsToSelector:@selector(introspectorGadgetInputView:didPerformKeyCommand:)]) {
        [_delegate introspectorGadgetInputView:self didPerformKeyCommand:keyCommand];
    }
}

#pragma mark -
#pragma mark UITextViewDelegate

- (void)textViewDidChangeSelection:(UITextView *)textView {
    
    [_selectionChangeTimer run:^(AWGCDTimer *timer) {
        NSRange selection = textView.selectedRange;
        
        CGFloat location = selection.location;
        if (selection.location + selection.length > 5) {
            location = selection.location + selection.length;
        }
        
        UIKeyModifierFlags modifiers = 0;
        if (selection.length != 0) {
            modifiers |= UIKeyModifierShift;
        }
        if (location == 1 || location == 3 || location == 7 || location == 9) {
            modifiers |= UIKeyModifierAlternate;
        }
        
        NSString *arrowKey = nil;
        if (modifiers & UIKeyModifierAlternate) {
            if (location == 3) {
                arrowKey = AWIntrospectorKeyInputLeftArrow;
            }
            else if (location == 7) {
                arrowKey = AWIntrospectorKeyInputRightArrow;
            }
            else if (location == 1) {
                arrowKey = AWIntrospectorKeyInputUpArrow;
            }
            else if (location == 9) {
                arrowKey = AWIntrospectorKeyInputDownArrow;
            }
        }
        else {
            if (location== 4) {
                arrowKey = AWIntrospectorKeyInputLeftArrow;
            }
            else if (location == 6) {
                arrowKey = AWIntrospectorKeyInputRightArrow;
            }
            else if (location == 0) {
                arrowKey = AWIntrospectorKeyInputUpArrow;
            }
            else if (location == 10) {
                arrowKey = AWIntrospectorKeyInputDownArrow;
            }
        }
        
        AWIntrospectorGadgetKeyboardCommand *command = [[AWIntrospectorGadgetKeyboardCommand alloc] init];
        command.input = arrowKey;
        command.modifierFlags = modifiers;
        [self didPerformIntrospectorKeyCommand:command];
        
        [self resetInputView];
    }];
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string {
    AWIntrospectorGadgetKeyboardCommand *command = [[AWIntrospectorGadgetKeyboardCommand alloc] init];
    command.input = string;
    [self didPerformIntrospectorKeyCommand:command];
    return NO;
}

@end

#endif
