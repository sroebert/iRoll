//
//  AWIntrospectorGadget.m
//  AWFoundation
//
//  Created by Steven Roebert on 19-11-2013.
//  Copyright (c) 2013 Steven Roebert. All rights reserved.
//

#if defined(DEBUG)

#import <objc/runtime.h>
#import <sys/sysctl.h>
#import <dlfcn.h>

static bool AWAmIBeingDebugged(void) {
	int                 junk;
	int                 mib[4];
	struct kinfo_proc   info;
	size_t              size;
    
	// Initialize the flags so that, if sysctl fails for some bizarre
	// reason, we get a predictable result.
    
	info.kp_proc.p_flag = 0;
    
	// Initialize mib, which tells sysctl the info we want, in this case
	// we're looking for information about a specific process ID.
    
	mib[0] = CTL_KERN;
	mib[1] = KERN_PROC;
	mib[2] = KERN_PROC_PID;
	mib[3] = getpid();
    
	// Call sysctl.
    
	size = sizeof(info);
	junk = sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
	assert(junk == 0);
    
	// We're being debugged if the P_TRACED flag is set.
	return ( (info.kp_proc.p_flag & P_TRACED) != 0 );
}

@interface UIView (AWRecursiveDescription)
- (NSString *)recursiveDescription;
@end

#if TARGET_CPU_ARM
#define DEBUGSTOP(signal) __asm__ __volatile__ ("mov r0, %0\nmov r1, %1\nmov r12, %2\nswi 128\n" : : "r"(getpid ()), "r"(signal), "r"(37) : "r12", "r0", "r1", "cc");
#define DEBUGGER do { int trapSignal = AWAmIBeingDebugged () ? SIGINT : SIGSTOP; DEBUGSTOP(trapSignal); if (trapSignal == SIGSTOP) { DEBUGSTOP (SIGINT); } } while (false);
#else
#define DEBUGGER do { int trapSignal = AWAmIBeingDebugged () ? SIGINT : SIGSTOP; __asm__ __volatile__ ("pushl %0\npushl %1\npush $0\nmovl %2, %%eax\nint $0x80\nadd $12, %%esp" : : "g" (trapSignal), "g" (getpid ()), "n" (37) : "eax", "cc"); } while (false);
#endif


#import "AWIntrospectorGadget.h"
#import "AWKeyboardHelper.h"
#import "AWIntrospectorView.h"
#import "AWIntrospectorViewParameters.h"
#import "AWIntrospectorGadget+Descriptions.h"
#import "AWIntrospectorGadget+Logs.h"
#import "AWIntrospectorAnimationHelper.h"
#import "AWIntrospectorGadgetInputView.h"
#import "AWGCDTimer.h"

static char AWIntrospectorViewParametersKey;

typedef void(^AWAlertViewChangeTextCallback)(UITextField *textField);

typedef NS_OPTIONS(NSUInteger, AWIntrospectorModifierKeys) {
    AWIntrospectorModifierKeyNone       = 0,
    AWIntrospectorModifierKeyShift      = 1 << 1,
    AWIntrospectorModifierKeyOption     = 1 << 2
};

typedef NS_ENUM(NSUInteger, AWIntrospectorArrowKey) {
    AWIntrospectorArrowKeyUnknown = 0,
    AWIntrospectorArrowKeyUp,
    AWIntrospectorArrowKeyLeft,
    AWIntrospectorArrowKeyDown,
    AWIntrospectorArrowKeyRight
};

@interface AWIntrospectorGadget () <UITextFieldDelegate, AWIntrospectorViewDelegate, AWIntrospectorGadgetInputViewDelegate> {
    UIWindow *_introspectWindow;
    AWIntrospectorView *_introspectView;
    AWIntrospectorGadgetInputView *_inputView;
    
    // Status bar overlay
    UIView *_statusBarOverlayView;
    UILabel *_leftInfoLabel;
    UILabel *_rightInfoLabel;
    NSString *_originalRightInfoLabelText;
    
    AWGCDTimer *_selectionChangeTimer;
    
    // Booleans to toggle different states: helpView, show changed views, show outlines and enable animation helper.
    BOOL _helpViewVisible;
    BOOL _changedViewsVisible;
    BOOL _outlinesVisible;
    BOOL _animationHelperEnabled;
    
    // This array is used to go through the view hierarchy and back
    NSArray *_viewHistory;
    // Array to store all changed views (alpha, frame, bg color or hidden parameters of the view)
    NSMutableArray *_changedViews;
    
//    AWAlertView *_activeInputAlertView;
    AWAlertViewChangeTextCallback _activeAlertViewChangeTextCallback;
    AWGCDTimer *_activeAlertViewChangeTextTimer;
    
    UIView *_helpContainerView;
    
    BOOL _active;
}

@end

@implementation AWIntrospectorGadget

+ (instancetype)sharedIntrospector {
	static id singleton = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		singleton = [(id)[super alloc] init];
	});
	return singleton;
}

#pragma mark -
#pragma mark Initialize

- (id)init {
	if ((self = [super init])) {
		_selectionChangeTimer = [AWGCDTimer timerWithTimeInterval:0];
	}
	return self;
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
//	[[AWInvocationCenter defaultCenter] removeObserver:self protocol:@protocol(AWKeyboardObserver) object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIWindowDidBecomeKeyNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark -
#pragma mark Enabled

- (void)setEnabled:(BOOL)enabled {
    if (_enabled == enabled) {
        return;
    }
    
    _enabled = enabled;
    if (_enabled) {
        [self setupIntrospectorWindow];
        [AWIntrospectorAnimationHelper sharedHelper].enabled = _animationHelperEnabled;
//        [[AWInvocationCenter defaultCenter] addObserver:self protocol:@protocol(AWKeyboardObserver) object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeKeyWindow:) name:UIWindowDidBecomeKeyNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    else {
        [self setHelpViewVisible:NO animated:NO];
        
//        [[AWInvocationCenter defaultCenter] removeObserver:self protocol:@protocol(AWKeyboardObserver) object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIWindowDidBecomeKeyNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
        [AWIntrospectorAnimationHelper sharedHelper].enabled = NO;
        
        _introspectWindow = nil;
        _introspectView = nil;
        _inputView = nil;
        _statusBarOverlayView = nil;
        _leftInfoLabel = nil;
        _rightInfoLabel = nil;
        _viewHistory = nil;
        _active = NO;
    }
}

#pragma mark -
#pragma mark Setup

- (void)setupIntrospectorWindow {
    
    // Input View
    _inputView = [[AWIntrospectorGadgetInputView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    _inputView.hidden = YES;
    _inputView.delegate = self;
    _inputView.supportedKeyboardCommands = [self supportedKeyboardCommands];
    
    [[UIApplication sharedApplication].keyWindow addSubview:_inputView];
    
    // Statusbar Overlay
    _statusBarOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    _statusBarOverlayView.hidden = YES;
    _statusBarOverlayView.backgroundColor = [UIColor blackColor];
    
    _leftInfoLabel = [[UILabel alloc] init];
    _leftInfoLabel.font = [UIFont boldSystemFontOfSize:12.0];
    _leftInfoLabel.textColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    _leftInfoLabel.backgroundColor = [UIColor blackColor];
    _leftInfoLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    [_statusBarOverlayView addSubview:_leftInfoLabel];
    
    _rightInfoLabel = [[UILabel alloc] init];
    _rightInfoLabel.textAlignment = NSTextAlignmentRight;
    _rightInfoLabel.font = [UIFont boldSystemFontOfSize:12.0];
    _rightInfoLabel.textColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    _rightInfoLabel.backgroundColor = [UIColor blackColor];
    _rightInfoLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    [_statusBarOverlayView addSubview:_rightInfoLabel];
    
    // AWIntrospectorView
    _introspectView = [[AWIntrospectorView alloc] init];
    _introspectView.delegate = self;
    
    if (![AWKeyboardHelper sharedHelper].keyboardVisible) {
        [_inputView becomeFirstResponder];
    }
    
    [self updateStatusbarOverlayToInitialState];
    
    if (!_changedViews) {
        _changedViews = [NSMutableArray array];
    }
    
    _active = NO;
    _changedViewsVisible = NO;
    _outlinesVisible = NO;
}

- (void)setActive:(BOOL)active {
    if (_active == active) {
        return;
    }
    
    _active = active;
    
    [self setTouchedView:nil];
    
    if (_active) {
        _introspectWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _introspectWindow.windowLevel = UIWindowLevelStatusBar + 1;
        
        _introspectWindow.rootViewController = [[UIViewController alloc] init];
        _statusBarOverlayView.frame = CGRectMake(0, 0, CGRectGetWidth(_introspectWindow.bounds), 20);
        _statusBarOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_introspectWindow.rootViewController.view addSubview:_statusBarOverlayView];
        
        _introspectView.frame = _introspectWindow.bounds;
        _introspectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_introspectWindow.rootViewController.view addSubview:_introspectView];
        
        UIWindow *currentKeyWindow = [UIApplication sharedApplication].keyWindow;
        [_introspectWindow makeKeyAndVisible];
        [currentKeyWindow makeKeyWindow];
    }
    else {
        _introspectWindow = nil;
        
        // if we're showing the help view, changed views or outlines and we're going inactive, hide them.
        [self setHelpViewVisible:NO animated:NO];
        [self setChangedViewsVisible:NO];
        [self setOutlinesVisible:NO];
    }
}

#pragma mark -
#pragma mark Observer

- (void)keyboardDidHideFromFrame:(CGRect)frame {
//    if (_activeInputAlertView) {
        return;
//    }
    
    if (![_inputView isFirstResponder]) {
        [_inputView becomeFirstResponder];
    }
}

- (void)didBecomeKeyWindow:(NSNotification *)notification {
//    if (_activeInputAlertView) {
        return;
//    }
    
    [notification.object addSubview:_inputView];
    
    if (![AWKeyboardHelper sharedHelper].keyboardVisible) {
        [_inputView becomeFirstResponder];
    }
}

#pragma mark -
#pragma mark Active

- (void)willResignActive {
    if (self.isEnabled) {
        [[UIApplication sharedApplication].keyWindow endEditing:YES];
        [_inputView removeFromSuperview];
    }
}

- (void)didBecomeActive {
    
    if (self.isEnabled) {
        [[UIApplication sharedApplication].keyWindow addSubview:_inputView];
        
        if (![AWKeyboardHelper sharedHelper].keyboardVisible) {
            [_inputView becomeFirstResponder];
        }
    }
}

#pragma mark -
#pragma mark AWIntrospectorGadgetInputViewDelegate

- (void)introspectorGadgetInputView:(AWIntrospectorGadgetInputView *)view didPerformKeyCommand:(AWIntrospectorGadgetKeyboardCommand *)command {
    
    if ([command.input length] == 0) {
        [self handleBackspace];
    }
    else if ([command.input isEqualToString:AWIntrospectorKeyInputUpArrow]) {
        [self handleArrowKey:AWIntrospectorArrowKeyUp modifiers:command.modifierFlags];
    }
    else if ([command.input isEqualToString:AWIntrospectorKeyInputDownArrow]) {
        [self handleArrowKey:AWIntrospectorArrowKeyDown modifiers:command.modifierFlags];
    }
    else if ([command.input isEqualToString:AWIntrospectorKeyInputLeftArrow]) {
        [self handleArrowKey:AWIntrospectorArrowKeyLeft modifiers:command.modifierFlags];
    }
    else if ([command.input isEqualToString:AWIntrospectorKeyInputRightArrow]) {
        [self handleArrowKey:AWIntrospectorArrowKeyRight modifiers:command.modifierFlags];
    }
    else {
        unichar key = [command.input characterAtIndex:0];
        [self handleKey:key];
    }
}

#pragma mark -
#pragma mark AWIntrospectorViewDelegate

- (void)introspectorView:(AWIntrospectorView *)view didChangeTouchedView:(UIView *)touchedView {
    [self updateTouchedView];
    [self updateStatusbarOverlayToInitialState];
}

#pragma mark -
#pragma mark Statusbar Overlay Update

/**
 Sets the Statusbar overlay to its initial state (showing `AWIntrospectorGadget` text in the left part and nothing in the right).
 */
- (void)updateStatusbarOverlayToInitialState {
    NSString *leftText = @"AWIntrospectorGadget";
    NSString *rightText = nil;
    if (_introspectView.touchedView) {
        leftText = NSStringFromClass([_introspectView.touchedView class]);
        rightText = NSStringFromCGRect(_introspectView.touchedView.frame);
    }
    [self updateStatusbarOverlayWithLeftText:leftText rightText:rightText];
}

/**
 This is the main method to change the texts in the status bar overlay.
 @param leftText Text to show in the left. Can be nil.
 @param rightText Text to show in the right part. Can be nil.
 */
- (void)updateStatusbarOverlayWithLeftText:(NSString *)leftText rightText:(NSString *)rightText {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetRightTextInStatusbarOverlay) object:nil];
    
    _statusBarOverlayView.hidden = !_active;
    
    _leftInfoLabel.text = leftText;
    _rightInfoLabel.text = rightText;
    
    CGFloat rightWidth = ceil([_rightInfoLabel sizeThatFits:CGSizeZero].width);
    
    _leftInfoLabel.frame = CGRectMake(5, 0, CGRectGetWidth(_statusBarOverlayView.bounds) - rightWidth - 10, CGRectGetHeight(_statusBarOverlayView.bounds));
    _rightInfoLabel.frame = CGRectMake(CGRectGetWidth(_statusBarOverlayView.bounds) - 5 - rightWidth, 0, rightWidth, CGRectGetHeight(_statusBarOverlayView.bounds));
}

/**
 This method updates only the right text. It will keep showing whatever it was in the left part.
 @param rightText Text to show in the right part of the status bar.
 */
- (void)updateStatusbarOverlayRightText:(NSString *)rightText {
    [self updateStatusbarOverlayWithLeftText:_leftInfoLabel.text rightText:rightText];
}

/**
 Shows temporary a text in the right part and then puts back the text that was previusly.
 @param rightText The temporary text to show in the right part.
 */
- (void)showTemporaryRightTextInStatusbarOverlay:(NSString *)rightText {
    
    if (!_originalRightInfoLabelText) {
        _originalRightInfoLabelText = [_rightInfoLabel.text copy];
        if (!_originalRightInfoLabelText) {
            _originalRightInfoLabelText = @"";
        }
    }
    
    [self updateStatusbarOverlayRightText:rightText];
    
    _statusBarOverlayView.hidden = NO;
	[self performSelector:@selector(resetRightTextInStatusbarOverlay) withObject:nil afterDelay:0.75];
}

/**
 Resets the status bar to its original texts.
 This method is used by `showTemporaryRightTextInStatusbarOverlay` after showing the temporary text for some time.
 */
- (void)resetRightTextInStatusbarOverlay {
    _statusBarOverlayView.hidden = !_active;
    [self updateStatusbarOverlayRightText:_originalRightInfoLabelText];
    _originalRightInfoLabelText = nil;
}

#pragma mark -
#pragma mark Utils

- (void)debugView:(UIView *)view {
    DEBUGGER;
}

- (AWIntrospectorViewParameters *)parametersForView:(UIView *)view {
    return objc_getAssociatedObject(view, &AWIntrospectorViewParametersKey);
}

/**
 Helper method to create an alert view with an input view in it.
 It also provides a block to handle the user input while typing, and completion block.
 */
- (void)retrieveUserInputWithTitle:(NSString *)title changeTextCallback:(AWAlertViewChangeTextCallback)changeTextCallback completion:(void(^)(NSString *input))completion {
    
//    _activeInputAlertView = [[AWAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
//    _activeInputAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
//    
//    UITextField *textField = [_activeInputAlertView textFieldAtIndex:0];
//    textField.enablesReturnKeyAutomatically = YES;
//    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
//    textField.autocorrectionType = UITextAutocorrectionTypeNo;
//    textField.delegate = self;
//    
//    _activeAlertViewChangeTextCallback = [changeTextCallback copy];
//    if (_activeAlertViewChangeTextCallback) {
//        _activeAlertViewChangeTextTimer = [AWGCDTimer timerWithTimeInterval:0.5];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeAlertViewText:) name:UITextFieldTextDidChangeNotification object:textField];
//    }
//    
//    [_activeInputAlertView showWithCompletion:^(AWAlertView *alertView, NSInteger clickedButtonIndex) {
//        if (clickedButtonIndex != alertView.cancelButtonIndex) {
//            if (completion) {
//                completion(textField.text);
//            }
//        }
//        _activeInputAlertView = nil;
//        
//        [_activeAlertViewChangeTextTimer cancel];
//        _activeAlertViewChangeTextTimer = nil;
//        
//        _activeAlertViewChangeTextCallback = nil;
//        
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:textField];
//    }];
}

- (void)setTouchedView:(UIView *)view {
    _introspectView.touchedView = view;
    [self updateTouchedView];
    [self updateStatusbarOverlayToInitialState];
}

/**
 Method to set the parameters object to the touched view.
 It also changes the statusbar overlay to its initial state.
 */
- (void)updateTouchedView {
    _viewHistory = @[];
    
    if (_introspectView.touchedView)  {
        AWIntrospectorViewParameters *parameters = [self parametersForView:_introspectView.touchedView];
        if (!parameters) {
            parameters = [[AWIntrospectorViewParameters alloc] initWithView:_introspectView.touchedView];
            objc_setAssociatedObject(_introspectView.touchedView, &AWIntrospectorViewParametersKey, parameters, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    [self updateStatusbarOverlayToInitialState];
}

- (void)enableAnimationChanges {
    _animationHelperEnabled = YES;
    [AWIntrospectorAnimationHelper sharedHelper].enabled = _animationHelperEnabled;
}

#pragma mark -
#pragma mark UITextFieldDelegate

/**
 Delegate methods por the alertView.
 */

- (void)didChangeAlertViewText:(NSNotification *)notification {
    [_activeAlertViewChangeTextTimer run:^(AWGCDTimer *timer) {
        _activeAlertViewChangeTextCallback(notification.object);
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    [_activeInputAlertView dismissWithClickedButtonIndex:_activeInputAlertView.firstOtherButtonIndex animated:YES];
    return NO;
}

#pragma mark -
#pragma mark Key Handling

- (NSArray *)supportedKeyboardCommands {
    NSArray *supportedCharacters = @[@" ", @"h", @"+", @"-", @"D", @"d", @"5", @"n", @"l", @"r", @"b",
                                     @"o", @"p", @"P", @"`", @"[", @"]", @"{", @"}", @"0", @"", @"?",
                                     @"a", @"A", @",", @".", @"<", @">"];
    NSMutableArray *supportedCommands = [NSMutableArray array];
    [supportedCharacters enumerateObjectsUsingBlock:^(NSString *character, NSUInteger idx, BOOL *stop) {
        AWIntrospectorGadgetKeyboardCommand *command = [[AWIntrospectorGadgetKeyboardCommand alloc] init];
        
        if (![[character lowercaseString] isEqualToString:character]) {
            command.input = [character lowercaseString];
            command.modifierFlags = UIKeyModifierShift;
        }
        else {
            command.input = character;
        }
        
        [supportedCommands addObject:command];
    }];
    
    NSArray *arrowKeys = @[AWIntrospectorKeyInputUpArrow, AWIntrospectorKeyInputDownArrow, AWIntrospectorKeyInputLeftArrow, AWIntrospectorKeyInputRightArrow];
    [arrowKeys enumerateObjectsUsingBlock:^(NSString *arrowKey, NSUInteger idx, BOOL *stop) {
        
        {
            AWIntrospectorGadgetKeyboardCommand *command = [[AWIntrospectorGadgetKeyboardCommand alloc] init];
            command.input = arrowKey;
            [supportedCommands addObject:command];
        }
        {
            AWIntrospectorGadgetKeyboardCommand *command = [[AWIntrospectorGadgetKeyboardCommand alloc] init];
            command.input = arrowKey;
            command.modifierFlags = UIKeyModifierShift;
            [supportedCommands addObject:command];
        }
        {
            AWIntrospectorGadgetKeyboardCommand *command = [[AWIntrospectorGadgetKeyboardCommand alloc] init];
            command.input = arrowKey;
            command.modifierFlags = UIKeyModifierAlternate;
            [supportedCommands addObject:command];
        }
        {
            AWIntrospectorGadgetKeyboardCommand *command = [[AWIntrospectorGadgetKeyboardCommand alloc] init];
            command.input = arrowKey;
            command.modifierFlags = UIKeyModifierAlternate;
            command.modifierFlags = UIKeyModifierShift;
            [supportedCommands addObject:command];
        }
    }];
    
    return supportedCommands;
}

- (void)handleBackspace {
    if (_active) {
        [self setTouchedView:nil];
    }
}

- (void)handleKey:(unichar)key {
    
    if (_helpViewVisible) {
        [self setHelpViewVisible:NO animated:YES];
        return;
    }
    
    // First handle keys that can be pressed when not in active state
    switch (key) {
        case ' ':
            [self setActive:!_active];
            return;
            
        case '?':
            [self setHelpViewVisible:!_helpViewVisible animated:YES];
            return;
            
        case 'a':
            _animationHelperEnabled = !_animationHelperEnabled;
            [AWIntrospectorAnimationHelper sharedHelper].enabled = _animationHelperEnabled;
            [self showTemporaryRightTextInStatusbarOverlay:[NSString stringWithFormat:@"Animation changes %@", _animationHelperEnabled ? @"enabled" : @"disabled"]];
            return;
            
        case 'A': {
            [self retrieveUserInputWithTitle:@"Set animation factor" changeTextCallback:NULL completion:^(NSString *input) {
                [AWIntrospectorAnimationHelper sharedHelper].animationDurationFactor = [input doubleValue];
                [self showTemporaryRightTextInStatusbarOverlay:[NSString stringWithFormat:@"Animation factor: %.2f", [AWIntrospectorAnimationHelper sharedHelper].animationDurationFactor]];
                [self enableAnimationChanges];
            }];
            return;
        }
            
        case ',':
            [AWIntrospectorAnimationHelper sharedHelper].animationDurationFactor *= 1.1;
            [self showTemporaryRightTextInStatusbarOverlay:[NSString stringWithFormat:@"Animation factor: %.2f", [AWIntrospectorAnimationHelper sharedHelper].animationDurationFactor]];
            [self enableAnimationChanges];
            return;
            
        case '.':
            [AWIntrospectorAnimationHelper sharedHelper].animationDurationFactor /= 1.1;
            [self showTemporaryRightTextInStatusbarOverlay:[NSString stringWithFormat:@"Animation factor: %.2f", [AWIntrospectorAnimationHelper sharedHelper].animationDurationFactor]];
            [self enableAnimationChanges];
            return;
            
        case '<':
            [AWIntrospectorAnimationHelper sharedHelper].animationDurationOffset -= 0.25;
            [self showTemporaryRightTextInStatusbarOverlay:[NSString stringWithFormat:@"Animation offset: %.2f", [AWIntrospectorAnimationHelper sharedHelper].animationDurationOffset]];
            [self enableAnimationChanges];
            return;
            
        case '>':
            [AWIntrospectorAnimationHelper sharedHelper].animationDurationOffset += 0.25;
            [self showTemporaryRightTextInStatusbarOverlay:[NSString stringWithFormat:@"Animation offset: %.2f", [AWIntrospectorAnimationHelper sharedHelper].animationDurationOffset]];
            [self enableAnimationChanges];
            return;
    }
    
    if (!_active) {
        return;
    }
    
    UIView *activeView = _introspectView.touchedView;
    
    BOOL shouldMarkViewAsChanged = NO;
    
    // Now handle other keys
    switch (key) {
        case 'h':
            activeView.hidden = !activeView.hidden;
            shouldMarkViewAsChanged = YES;
            break;
            
        case '+':
            if (activeView.alpha < 1.0f) {
                activeView.alpha += 0.05f;
                shouldMarkViewAsChanged = YES;
            }
            break;
            
        case '-':
            if (activeView.alpha > 0.0f) {
                activeView.alpha -= 0.05f;
                shouldMarkViewAsChanged = YES;
            }
            break;
            
        case 'D':
            if (activeView) {
//                DLog(@"\n%@", activeView);
            }
            
        case 'd':
            if (activeView) {
//                DLog(@"\n%@", [activeView recursiveDescription]);
            }
            break;
            
        case '5':
            if (activeView) {
//                [activeView alignInSuperviewWithAlignment:AWViewAlignmentCenter edgeInsets:UIEdgeInsetsZero];
                shouldMarkViewAsChanged = YES;
            }
            break;
            
        case 'n':
            [activeView setNeedsDisplay];
            break;
            
        case 'l':
            [activeView setNeedsLayout];
            break;
            
        case 'r':
            [self resetChangedViews];
            break;
            
        case 'b':
            if (activeView) {
//                [self retrieveUserInputWithTitle:@"Set backgroundColor" changeTextCallback:^(UITextField *textField) {
//                    textField.backgroundColor = [UIColor colorWithHexString:textField.text];
//                } completion:^(NSString *input) {
//                    UIColor *newBackgroundColor = [UIColor colorWithHexString:input];
//                    if (newBackgroundColor) {
//                        activeView.backgroundColor = newBackgroundColor;
//                        [self markViewAsChanged:activeView];
//                    }
//                }];
            }
            break;
            
        case 'o':
            [self setOutlinesVisible:!_outlinesVisible];
            break;
            
        case 'p':
            if (activeView) {
                [self logProppertiesForView:activeView];
            }
            break;
            
        case 'P':
            if (activeView) {
                [self logAccesibilityProppertiesForObject:activeView];
            }
            break;
            
        case '`':
            if (activeView) {
                [self debugView:activeView];
            }
            break;
            
        case ']':
        case '[': {
            if (!activeView) {
                break;
            }
            
            NSInteger offset = (key == ']' ? 1 : -1);
            
            NSArray *subviews;
            if (activeView.superview) {
                subviews = activeView.superview.subviews;
            }
            else {
                subviews = [UIApplication sharedApplication].windows;
            }
            
            if ([subviews count] == 0 || [subviews count] == 1) {
                [_introspectView shakeTouchedView];
                break;
            }
            
            NSInteger newIndex = [subviews indexOfObject:activeView] + offset;
            if (newIndex < 0) {
                newIndex = [subviews count] - 1;
            }
            else if (newIndex == [subviews count]) {
                newIndex = 0;
            }
            
            [self setTouchedView:subviews[newIndex]];
            break;
        }
            
        case '}':
            if (!activeView) {
                break;
            }
            
            if ([activeView.subviews count] > 0) {
                
                NSArray *newViewHistory = _viewHistory;
                UIView *subview = nil;
                if ([_viewHistory count] > 0) {
                    subview = [_viewHistory lastObject];
                    newViewHistory = [newViewHistory subarrayWithRange:NSMakeRange(0, [newViewHistory count] - 1)];
                }
                else {
                    subview = [activeView.subviews firstObject];
                    newViewHistory = @[];
                }
                
                [self setTouchedView:subview];
                _viewHistory = newViewHistory;
            }
            else {
                [_introspectView shakeTouchedView];
            }
            break;
            
        case '{': {
            if (!activeView) {
                break;
            }
            
            UIView *superview = activeView.superview;
            if (!superview) {
                [_introspectView shakeTouchedView];
            }
            else {
                NSArray *newViewHistory = [_viewHistory arrayByAddingObject:activeView];
                
                [self setTouchedView:superview];
                _viewHistory = newViewHistory;
            }
            break;
        }
            
        case '0':
            [self setChangedViewsVisible:!_changedViewsVisible];
            break;
    }
    
    if (shouldMarkViewAsChanged) {
        [self markViewAsChanged:activeView];
    }
    
//    DLog(@"Key: %c", key);
}

- (void)handleArrowKey:(AWIntrospectorArrowKey)arrowKey modifiers:(UIKeyModifierFlags)modifiers {
    
    if (_introspectView.touchedView && _active) {
        [self handleArrowKey:arrowKey modifiers:modifiers view:_introspectView.touchedView];
//        DLog(@"Key: %d (%d)", arrowKey, modifiers);
    }
}

- (void)handleArrowKey:(AWIntrospectorArrowKey)arrowKey modifiers:(UIKeyModifierFlags)modifiers view:(UIView *)view {
    
    CGFloat offset = 1;
    if (modifiers & UIKeyModifierShift) {
        offset = 10;
    }
    
    if (modifiers & UIKeyModifierAlternate) {
        CGRect newBounds = view.bounds;
        switch (arrowKey) {
            case AWIntrospectorArrowKeyUp:
                newBounds.size.height -= offset;
                break;
            case AWIntrospectorArrowKeyLeft:
                newBounds.size.width -= offset;
                break;
            case AWIntrospectorArrowKeyDown:
                newBounds.size.height += offset;
                break;
            case AWIntrospectorArrowKeyRight:
                newBounds.size.width += offset;
                break;
            default:
                break;
        }
        view.bounds = newBounds;
        
    }
    else {
        CGPoint newCenter = view.center;
        switch (arrowKey) {
            case AWIntrospectorArrowKeyUp:
                newCenter.y -= offset;
                break;
            case AWIntrospectorArrowKeyLeft:
                newCenter.x -= offset;
                break;
            case AWIntrospectorArrowKeyDown:
                newCenter.y += offset;
                break;
            case AWIntrospectorArrowKeyRight:
                newCenter.x += offset;
                break;
            default:
                break;
        }
        view.center = newCenter;
    }
    
    [self markViewAsChanged:view];
}

#pragma mark - Mark view as changed
/**
 Inserts the view into the changedViews array if it wasn't already in there.
 */
- (void)markViewAsChanged:(UIView *)view {
    if (view && ![_changedViews containsObject:view]) {
        [_changedViews addObject:view];
    }
}

#pragma mark - Log changes to views

/**
 Checks the `AWIntrospectorViewParameters` object of a view and logs all the changes found on it.
 @param view The view that you want to check for changes.
 @return a string containing all the changes for that view, or empty string if there weren't any changes.
 */
- (NSString *)changesForView:(UIView *)view {
    
    NSString *viewClass = NSStringFromClass([view class]);
    NSMutableString *log = [NSMutableString string];
    
    AWIntrospectorViewParameters *parameters = [self parametersForView:view];
    if (parameters) {
        if (!CGRectEqualToRect(parameters.frame, view.frame)){
            [log appendFormat:@"#%@#.frame = CGRectMake(%.1f, %.1f, %.1f, %.1f)\n", viewClass, CGRectGetMinX(view.frame), CGRectGetMinY(view.frame), CGRectGetWidth(view.frame), CGRectGetHeight(view.frame)];
        }
        
        if (parameters.alpha != view.alpha) {
            [log appendFormat:@"#%@#.alpha = %.2f\n", viewClass, view.alpha];
        }
        
        if (parameters.hidden != view.hidden) {
            [log appendFormat:@"#%@#.hidden = %@\n", viewClass, (view.hidden) ? @"YES" : @"NO"];
        }
        
        if (![parameters.backgroundColor isEqual:view.backgroundColor] && (parameters.backgroundColor && view.backgroundColor)) {
            [log appendFormat:@"#%@#.backgroundColor = %@\n", viewClass, [self describeColor:view.backgroundColor]];
        }
    }
    
    return log;
}

/**
 Loops through the changed views array to get what parameters have changed and logs them.
 It also toggles the changed views rect visible and shows a temporary string in the right part of the statusbar overlay informing about it.
 
 @param visible Toggles visibility of the changed views.
 */

- (void)setChangedViewsVisible:(BOOL)visible {
    if (_changedViewsVisible == visible) {
        return;
    }
    
    _changedViewsVisible = visible;
    if (_changedViewsVisible) {
        [self setOutlinesVisible:NO];
        
        NSMutableArray *outlineRectangles = [NSMutableArray arrayWithCapacity:[_changedViews count]];
        NSMutableString *log = [NSMutableString string];
        [_changedViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
            [log appendString:[self changesForView:view]];
            
            // append the rect to be shown in the introspector view
            CGRect rect = [view.superview convertRect:view.frame toView:_introspectView];
            NSValue *rectValue = [NSValue valueWithCGRect:rect];
            [outlineRectangles addObject:rectValue];
        }];
        
        _introspectView.outlineRectangles = outlineRectangles;
        
        if (log.length > 0){
//            DLog(@"\n\n%@", log);
        }
        else {
//            DLog(@"\n\nAWIntrospect: No changes in any view.\n");
        }
    }
    else {
        _introspectView.outlineRectangles = nil;
    }
    
    NSString *rightText = [NSString stringWithFormat:@"Show changed views is %@", (_changedViewsVisible) ? @"on" : @"off"];
    [self showTemporaryRightTextInStatusbarOverlay:rightText];
}



#pragma mark - Reset Changed Views
/**
 Loops through the changed views array reseting the properties of the view that changed (frame, alpha, hidden and backgroundColor) to its
 original state, removes the `AWIntrospectorViewParameters` object from that view, removes the outlines for changed views and finally empty the
 changed views array.
 */
- (void)resetChangedViews {
    [_changedViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        AWIntrospectorViewParameters *parameters = [self parametersForView:view];
        view.frame = parameters.frame;
        view.alpha = parameters.alpha;
        view.hidden = parameters.hidden;
        view.backgroundColor = parameters.backgroundColor;
        
        objc_removeAssociatedObjects(parameters);
    }];
    
    [_changedViews removeAllObjects];
    _introspectView.outlineRectangles = nil;
    
    [self showTemporaryRightTextInStatusbarOverlay:@"Changed views reset."];
}

#pragma mark - View outlines

/**
 Helper method to add oulines rect to all subviews of a given view.
 
 @param view The parent view where to start checking the outlines.
 @param outlineRectangles The array containing all the rects for the outlines.
 */
- (void)addOutlinesForSubviewsOfView:(UIView *)view outlines:(NSMutableArray *)outlineRectangles {
    [view.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        CGRect rect = [subview convertRect:subview.bounds toView:_introspectView];
        NSValue *rectValue = [NSValue valueWithCGRect:rect];
        [outlineRectangles addObject:rectValue];
        [self addOutlinesForSubviewsOfView:subview outlines:outlineRectangles];
    }];
}

/**
 Toggles the outlines visibility.
 If a view is selected, then it will show the outlines for that view and all its subviews.
 If nothing is selected, it will show the whole window outlines (and its children views).
 It will loop through the whole view hierarchy recursively.
 
 @param visible YES to show the outlines.
 */
- (void)setOutlinesVisible:(BOOL)visible {
    if (_outlinesVisible == visible) {
        return;
    }
    
    _outlinesVisible = visible;
    UIView *activeView = _introspectView.touchedView;
    if (_outlinesVisible) {
        [self setChangedViewsVisible:NO];
        
        NSMutableArray *outlineRectangles = [NSMutableArray array];
        if (activeView){
            [self addOutlinesForSubviewsOfView:activeView outlines:outlineRectangles];
        }
        else{
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            [self addOutlinesForSubviewsOfView:window outlines:outlineRectangles];
        }
        _introspectView.outlineRectangles = outlineRectangles;
        [self showTemporaryRightTextInStatusbarOverlay:@"Showing view outlines."];
    }
    else {
        _introspectView.outlineRectangles = nil;
        [self showTemporaryRightTextInStatusbarOverlay:@"View outlines hidden."];
    }
}

#pragma mark - Help View


/**
 Toggles the help view visibility.
 It also creates the HelpView and sets an animation to show it.
 
 @param visible YES to show the help view.
 @param animated YES to show the view with an animation
 */
- (void)setHelpViewVisible:(BOOL)visible animated:(BOOL)animated {
    if (_helpViewVisible == visible) {
        return;
    }
    
    _helpViewVisible = visible;
    _introspectWindow.userInteractionEnabled = !_helpViewVisible;
    if (_helpViewVisible) {
        
        [self setTouchedView:nil];
        
        [self updateStatusbarOverlayWithLeftText:@"Help" rightText:@"press ? to close"];
        
        _helpContainerView = [[UIView alloc] init];
//        [[UIApplication sharedApplication].keyWindow addSubview:_helpContainerView withAlignment:AWViewAlignmentFill edgeInsets:UIEdgeInsetsZero];
        
        UIWebView *webView = [[UIWebView alloc] init];
        webView.opaque = NO;
        webView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.85f];
        webView.alpha = 0;
//        [_helpContainerView addSubview:webView withAlignment:AWViewAlignmentFill edgeInsets:UIEdgeInsetsMake(20, 0, 0, 0)];
        
        NSMutableString *helpString = [NSMutableString stringWithString:@"<html>"];
        [helpString appendString:@"<head><style>"];
        [helpString appendString:@"body { background-color:rgba(0, 0, 0, 0.0); font:10pt helvetica; line-height: 15px margin-left:5px; margin-right:5px; margin-top:20px; color:rgb(240, 240, 240); } a { color:#45e0fe; font-weight:bold; } h1 { width:100%; font-size:14pt; border-bottom: 1px solid white; margin-top:10px; } h2 { font-size:11pt; margin-left:3px; margin-bottom:2px; } .name { margin-left:7px; } .key { float:right; margin-right:7px; } .key, .code { font-family:Courier; font-weight:bold; color:#CE8B39; } .spacer { height:10px; } p { margin-left: 7px; margin-right: 7px; } .logo { width:20px; height:20px; }"];
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
            [helpString appendString:@"body { font-size:11pt; width:500px; margin:0 auto; }"];
        
        [helpString appendString:@"</style></head><body><h1>AWIntrospectorGadget</h1>"];
        [helpString appendString:@"<p><img class='logo' src='http://profile.ak.fbcdn.net/hprofile-ak-prn1/41803_281110885306438_956810546_q.jpg'> &#9835 Tataratara inspector gadget... &#9835</p>"];
        
        [helpString appendString:@"<div class='bindings'><h1>Key Bindings</h1>"];
        
        [helpString appendString:@"<h2>General</h2>"];
        [helpString appendString:@"<div><span class='name'>Invoke Introspector</span><div class='key'>spacebar</div></div>"];
        [helpString appendString:@"<div><span class='name'>Toggle Help</span><div class='key'>?</div></div>"];
        [helpString appendString:@"<div><span class='name'>Toggle show changed views</span><div class='key'>0</div></div>"];
        [helpString appendString:@"<div><span class='name'>Reset all changed views</span><div class='key'>r</div></div>"];
        [helpString appendString:@"<div class='spacer'></div>"];
        
        [helpString appendString:@"<h2>Animations</h2>"];
        [helpString appendString:@"<div><span class='name'>Toggle animation duration changes</span><div class='key'>a</div></div>"];
        [helpString appendString:@"<div><span class='name'>Set animation duration factor</span><div class='key'>A</div></div>"];
        [helpString appendString:@"<div><span class='name'>Decrease animation duration factor</span><div class='key'>,</div></div>"];
        [helpString appendString:@"<div><span class='name'>Increase animation duration factor</span><div class='key'>.</div></div>"];
        [helpString appendString:@"<div><span class='name'>Decrease animation duration offset</span><div class='key'>&lt;</div></div>"];
        [helpString appendString:@"<div><span class='name'>Increase animation duration offset</span><div class='key'>&gt;</div></div>"];
        [helpString appendString:@"<div class='spacer'></div>"];
        
        [helpString appendString:@"<h2>When a view is selected</h2>"];
        [helpString appendString:@"<div><span class='name'>Log Properties</span><div class='key'>p</div></div>"];
        [helpString appendString:@"<div><span class='name'>Log Accessibility Properties</span><div class='key'>P</div></div>"];
        [helpString appendString:@"<div><span class='name'>Log Description for View</span><div class='key'>D</div></div>"];
        [helpString appendString:@"<div><span class='name'>Log Recursive Description for View</span><div class='key'>d</div></div>"];
        [helpString appendString:@"<div><span class='name'>Toggle View Outlines</span><div class='key'>o</div></div>"];
        [helpString appendString:@"<div><span class='name'>Enter GDB</span><div class='key'>`</div></div>"];
        [helpString appendString:@"<div class='spacer'></div>"];
        
        [helpString appendString:@"<div><span class='name'>Go to next sibling of the view</span><div class='key'>]</div></div>"];
        [helpString appendString:@"<div><span class='name'>Go to previus sibling of the view</span><div class='key'>[</div></div>"];
        [helpString appendString:@"<div><span class='name'>Move up in view hierarchy</span><div class='key'>{</div></div>"];
        [helpString appendString:@"<div><span class='name'>Move back down in view hierarchy</span><div class='key'>}</div></div>"];
        [helpString appendString:@"<div class='spacer'></div>"];
        
        [helpString appendString:@"<div><span class='name'>Center in Superview</span><div class='key'>5</div></div>"];
        [helpString appendString:@"<div><span class='name'>Move Up View </span><div class='key'> \uE232 </div></div>"];
        [helpString appendString:@"<div><span class='name'>Move Down View</span><div class='key'> \uE233 </div></div>"];
        [helpString appendString:@"<div><span class='name'>Move Left View</span><div class='key'> \uE235 </div></div>"];
        [helpString appendString:@"<div><span class='name'>Move Right View</span><div class='key'> \uE234 </div></div>"];
        [helpString appendString:@"<div class='spacer'></div>"];
        
        [helpString appendString:@"<div><span class='name'>Increase Width</span><div class='key'>alt + \uE234 </div></div>"];
        [helpString appendString:@"<div><span class='name'>Decrease Width</span><div class='key'>alt + \uE235 </div></div>"];
        [helpString appendString:@"<div><span class='name'>Increase Height</span><div class='key'>alt + \uE233 </div></div>"];
        [helpString appendString:@"<div><span class='name'>Decrease Height</span><div class='key'>alt + \uE232 </div></div>"];
        [helpString appendString:@"<div class='spacer'></div>"];
        
        [helpString appendString:@"<div><span class='name'>Increase Alpha</span><div class='key'>+</div></div>"];
        [helpString appendString:@"<div><span class='name'>Decrease Alpha</span><div class='key'>-</div></div>"];
        [helpString appendString:@"<div><span class='name'>Hide/Show view</span><div class='key'>h</div></div>"];
        [helpString appendString:@"<div><span class='name'>Set backgroundColor</span><div class='key'>b</div></div>"];
        [helpString appendString:@"<div class='spacer'></div>"];
        
        [helpString appendString:@"<div><span class='name'>Call setNeedsDisplay</span><div class='key'>n</div></div>"];
        [helpString appendString:@"<div><span class='name'>Call setNeedsLayout</span><div class='key'>l</div></div>"];
        [helpString appendString:@"</div>"];
        
        [helpString appendString:@"<div class='spacer'></div>"];
        
        if (animated) {
            [UIView animateWithDuration:0.1 animations:^{
                webView.alpha = 1.0;
            } completion:^(BOOL finished) {
                [webView loadHTMLString:helpString baseURL:nil];
            }];
        }
        else {
            webView.alpha = 1.0;
            [webView loadHTMLString:helpString baseURL:nil];
        }
    }
    else {
        if (animated) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                [[_helpContainerView.subviews firstObject] setAlpha:0];
            } completion:^(BOOL finished) {
                [_helpContainerView removeFromSuperview];
                _helpContainerView = nil;
                [self updateStatusbarOverlayToInitialState];
            }];
        }
        else {
            [_helpContainerView removeFromSuperview];
            _helpContainerView = nil;
            [self updateStatusbarOverlayToInitialState];
        }
    }
}

@end

#endif
