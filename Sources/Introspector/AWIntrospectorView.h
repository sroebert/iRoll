//
//  AWIntrospectorView.h
//  AWFoundation
//
//  Created by Steven Roebert on 19-11-2013.
//  Copyright (c) 2013 Steven Roebert. All rights reserved.
//

#if defined(DEBUG)

@protocol AWIntrospectorViewDelegate;

@interface AWIntrospectorView : UIView

@property (nonatomic, strong) UIView *touchedView;

- (void)bounceTouchedView;
- (void)shakeTouchedView;

@property (nonatomic, weak) id <AWIntrospectorViewDelegate> delegate;
@property (nonatomic, copy) NSArray *outlineRectangles; // this array will contain the rects to show (outlines or changed views).

@end

@protocol AWIntrospectorViewDelegate <NSObject>
@optional

- (void)introspectorView:(AWIntrospectorView *)view didChangeTouchedView:(UIView *)touchedView;

@end

#endif
