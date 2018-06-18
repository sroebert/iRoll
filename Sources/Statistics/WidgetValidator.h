//
//  WidgetValidator.h
//  iRoll
//
//  Created by Steven Roebert on 14/03/2010.
//  Copyright 2010 Apple Inc. All rights reserved.
//
//	Validator for widgets. Checks if the total upper score is possible with the currently
//	used categories. If not, the widget will not be valid and we do not have to calculate
//	the potentials for it, as it can never be reached.
//

#import "Widget.h"

@interface WidgetValidator : NSObject

- (BOOL)validateWidget:(Widget *)widget;
- (BOOL)validateWidgetHash:(int)hash;

@end
