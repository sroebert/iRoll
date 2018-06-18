//
//  ImageViewController.m
//  iRoll
//
//  Created by Steven Roebert on 27/02/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//

#import "ImageViewController.h"


@implementation ImageViewController {
	UIImage *_imageViewImage;
}

- (id)initWithImage:(UIImage *)image {
	if ((self = [super initWithNibName:@"ImageViewController" bundle:nil])) {
		_imageViewImage = image;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	_imageView.image = _imageViewImage;
}

@end
