//
//  LiveImageView.m
//  SampleQXCameraKit
//
//  Created by Hirakawa Akira on 10/10/14.
//  Copyright (c) 2014 Hirakawa Akira. All rights reserved.
//

#import "AFTouchView.h"

@implementation AFTouchView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    CGPoint point = [[touches anyObject] locationInView:self];
    
    double base = [[UIScreen mainScreen] bounds].size.width;

    // in this view
    double x = point.x / base;
    double y = point.y / base;
    
    // in live view
    double baseWidth = 480;
    double liveX = 480;
    double liveY = 640;
    
    x = ((x * baseWidth) +  0) / liveX * 100;
    y = ((y * baseWidth) + 80) / liveY * 100;
    
    //change
    NSLog(@"x:%f y:%f", point.x, point.y);
    NSLog(@"%f %f", x, y);

    [self.manager.api setTouchAFPosition:x y:y block:^(NSDictionary *json, BOOL isSucceeded){
        NSLog(@"%@", json);
    }];
}
@end
