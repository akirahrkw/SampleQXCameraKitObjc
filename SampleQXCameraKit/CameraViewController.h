//
//  CameraViewController.h
//  InstaQX
//
//  Created by Hirakawa Akira on 6/9/14.
//  Copyright (c) 2014 Hirakawa Akira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFTouchView.h"

@interface CameraViewController : UIViewController

@property IBOutlet AFTouchView *touchView;

@property IBOutlet UIImageView *liveImageView;

@property (weak, nonatomic) IBOutlet UIButton *zoomInButton;
@property (weak, nonatomic) IBOutlet UIButton *zoomOutButton;

- (IBAction)takePicture:(id)sender;
@end
