//
//  DirectionPanel.m
//  SpaceBar
//
//  Created by dmiau on 7/12/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "DirectionPanel.h"
#import "AppDelegate.h"
#import "../ViewController.h"
#import "../Map/Route.h"

@implementation DirectionPanel

- (id)initWithFrame:(CGRect)frame ViewController:(ViewController*) viewController{
    
    self = [super initWithFrame:frame];
    if (self){
        
        self.rootViewController = viewController;
        
        //-------------------
        // Set up the view
        //-------------------
        
        // set up the color of the view
        [self setBackgroundColor:[UIColor colorWithRed: 0.94 green:0.94 blue:0.94
                                                 alpha:1.0]];
        // dismiss button
        UIButton*  dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        dismissButton.frame =
            CGRectMake(frame.size.width*0.1, frame.size.height*0.5, 60, 20);
        [dismissButton setTitle:@"Dismiss" forState:UIControlStateNormal];
        dismissButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [dismissButton setBackgroundColor:[UIColor grayColor]];
        [dismissButton addTarget:self action:@selector(dismissButtonAction)
                  forControlEvents:UIControlEventTouchDown];
        
        // add drop shadow
        //            self.layer.cornerRadius = 8.0f;
        dismissButton.layer.masksToBounds = NO;
        //            self.layer.borderWidth = 1.0f;
        
        dismissButton.layer.shadowColor = [UIColor grayColor].CGColor;
        dismissButton.layer.shadowOpacity = 0.8;
        dismissButton.layer.shadowRadius = 12;
        dismissButton.layer.shadowOffset = CGSizeMake(12.0f, 12.0f);
        [self addSubview:dismissButton];
    }
    
    return self;
}

- (void)addPanel{
    [self.rootViewController.view addSubview:self];
    // remove all SpaceTokens
    [self.rootViewController.spaceBar removeAllSpaceTokens];
}

- (void)removePanel{
    // Do some clean up
    // Remove route annotation and the route
    [self.rootViewController.mapView removeOverlay:
     self.rootViewController.activeRoute.route.polyline];
    self.rootViewController.activeRoute = nil;
    
    // Reset Spacebar
    [self.rootViewController.spaceBar resetSpaceBar];
    [self removeFromSuperview];
}

- (void)dismissButtonAction{
//    [self.rootViewController initSpaceBarWithTokens];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
