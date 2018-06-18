//
//  RulesViewController.m
//  iRoll
//
//  Created by Steven Roebert on 27/02/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController () {
	NSString *_webContent;
}

- (void)hideGradientBackground:(UIView *)parentView;

@end


@implementation InfoViewController

- (id)initWithText:(NSString *)text {
	if ((self = [super initWithNibName:@"InfoViewController" bundle:nil])) {
		_webContent = [text copy];
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self hideGradientBackground:_webView]; 
	[_webView loadHTMLString:_webContent baseURL:nil];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
	// Open a url in Safari when clicked
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		[[UIApplication sharedApplication] openURL:request.URL];
		return NO;
	}
	return YES;
}

- (void)hideGradientBackground:(UIView *)parentView
{
	for (UIView *subview in parentView.subviews)
	{
		if ([subview isKindOfClass:[UIImageView class]]) {
			subview.hidden = YES;
		}
		[self hideGradientBackground:subview];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([_webView respondsToSelector:@selector(scrollView)]) {
        [[_webView scrollView] flashScrollIndicators];
    }
}


@end
