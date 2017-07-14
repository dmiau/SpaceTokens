//
//  DirectionPanel.m
//  NavTools
//
//  Created by dmiau on 7/12/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "DirectionPanel.h"
#import "AppDelegate.h"
#import "ViewController.h"
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

-(void)viewWillAppear:(BOOL)animated{
    
}

- (void)addPanel{
    [self.rootViewController.view addSubview:self];
    self.rootViewController.navTools.spaceBarMode = PATH;
}

- (void)removePanel{
    // Do some clean up
    // Remove route annotation and the route
    [self.rootViewController.mapView removeOverlay:
     self.rootViewController.navTools.activeRoute.polyline];
    self.rootViewController.navTools.activeRoute = nil;
    
    // Reset Spacebar
    [self.rootViewController.navTools resetSpaceBar];
    [self removeFromSuperview];
}

- (void)dismissButtonAction{
    [self.rootViewController.mainViewManager showDefaultPanel];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
