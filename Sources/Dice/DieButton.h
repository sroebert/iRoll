//
//  DiceButton.h
//  iRoll
//
//  Created by Steven Roebert on 18/02/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//
//	Button showing a die face. The button can be selected and highlighted. Depending
//	on the state, the die face will have a different color. The value of the die can be
//	set, depending on the value a different amount of dots will be drawn. When a new value
//	is set, the die can optionally show a kind of rolling animation where different values
//	are shown before the final roll value is set.
//

@protocol DieButtonDelegate <NSObject>

- (void)dieButtonAnimationCompleted:(id)sender;

@end

@interface DieButton : UIButton

@property (nonatomic, weak) id <DieButtonDelegate> delegate;
@property (nonatomic, readonly) int value;

- (void)setDieValue:(int)newValue animated:(BOOL)animated;

@end
