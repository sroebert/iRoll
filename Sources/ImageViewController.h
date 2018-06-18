//
//  ImageViewController.h
//  iRoll
//
//  Created by Steven Roebert on 27/02/2010.
//  Copyright 2010 Steven Roebert. All rights reserved.
//
//	Class used for testing purposes. It is a simple controller for showing one image.
//

@protocol ImageViewControllerDelegate <NSObject>
@optional

- (void)done;

@end

@interface ImageViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) id <ImageViewControllerDelegate> delegate;

@end
