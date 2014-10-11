//
//  CameraViewController.m
//  InstaQX
//
//  Created by Hirakawa Akira on 6/9/14.
//  Copyright (c) 2014 Hirakawa Akira. All rights reserved.
//

#import "CameraViewController.h"

#import <QXCameraKit/QXCameraKit.h>

@interface CameraViewController ()

@property (strong, nonatomic) QXAPIManager *manager;
@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
}

- (void)viewDidAppear:(BOOL)animated {
    [self setupGesture];
    [self performSelectorInBackground:@selector(openConnection) withObject:NULL];
}

#pragma mark UILongPressGestureRecognizer methods
- (void)setupGesture {
    UILongPressGestureRecognizer* gestureRecognizerZoomIn = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                          action:@selector(didTapLongPressedZoomIn:)];
    [_zoomInButton addGestureRecognizer:gestureRecognizerZoomIn];
    
    UILongPressGestureRecognizer* gestureRecognizerZoomOut = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                           action:@selector(didTapLongPressedZoomOut:)];
    [_zoomOutButton addGestureRecognizer:gestureRecognizerZoomOut];
}

- (void)didTapLongPressedZoomIn:(UILongPressGestureRecognizer *)gestureRecognizer {
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            [self.manager.api startZoomInWithAPIResponseBlock:^(NSDictionary *json, BOOL isSucceeded){
                NSLog(@"%@", json);
            }];
            break;
        case UIGestureRecognizerStateEnded:
            [self.manager.api stopZoomInWithAPIResponseBlock:^(NSDictionary *json, BOOL isSucceeded){
                NSLog(@"%@", json);
            }];
            break;
        default:
            break;
    }
}

- (void)didTapLongPressedZoomOut:(UILongPressGestureRecognizer *)gestureRecognizer {
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            [self.manager.api startZoomOutWithAPIResponseBlock:^(NSDictionary *json, BOOL isSucceeded){
                NSLog(@"%@", json);
            }];
            break;
        case UIGestureRecognizerStateEnded:
            [self.manager.api stopZoomOutWithAPIResponseBlock:^(NSDictionary *json, BOOL isSucceeded){
                NSLog(@"%@", json);
            }];
            break;
        default:
            break;
    }
}

- (IBAction)takePicture:(id)sender {
    __weak typeof (self) selfie = self;
    [self.manager takePicture:^(NSDictionary *json, BOOL isSucceeded){
        
        UIImage *image = [selfie.manager didTakePicture:json];
        
        float width = CGImageGetWidth(image.CGImage);
        float height = CGImageGetHeight(image.CGImage);
        
        int x = (width - height) / 2;
        CGRect cropRect = CGRectMake( x, 0, 1080, 1080);

        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
        UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        
        width = CGImageGetWidth(croppedImage.CGImage);
        height = CGImageGetHeight(croppedImage.CGImage);

        BOOL clockwise = NO;
        CGSize size = croppedImage.size;
        UIGraphicsBeginImageContext(CGSizeMake(size.height, size.width));
        [[UIImage imageWithCGImage:[croppedImage CGImage] scale:1.0 orientation:clockwise ? UIImageOrientationRight : UIImageOrientationLeft] drawInRect:CGRectMake(0,0,size.height ,size.width)];
        UIImage* rotatedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImageWriteToSavedPhotosAlbum(rotatedImage,nil,nil,nil);
    }];
}

#pragma mark API methods
- (void)openConnection {
    __weak typeof (self) selfie = self;
    FetchImageBlock block = ^(UIImage *image, NSError *error) {
        float height = CGImageGetHeight(image.CGImage);
        float width = CGImageGetWidth(image.CGImage);
        
        int x = (width - height) / 2;
        CGRect cropRect = CGRectMake( x, 0, 480, 480);
        
        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
        UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        
        @synchronized(self) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [selfie.liveImageView setImage:croppedImage];
            });
        }
    };
    
    self.manager = [[QXAPIManager alloc] init];
    self.touchView.manager = _manager;
    self.liveImageView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    self.touchView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    [_manager discoveryDevicesWithFetchImageBlock:block];
}

@end
