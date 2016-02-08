//
//  SpaceBar.m
//  PlayGround
//
//  Created by Daniel on 2/1/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SpaceBar.h"
#import "SpaceMark.h"

// SpaceBar extension
@interface SpaceBar ()
{
    NSTimer *iv_updateUITimer;
}


@end

@implementation SpaceBar

//----------------
// initialization
//----------------
- (id)initWithMapView: (MKMapView *) myMapView {
    self = [super init];
    if (self) {
        // Initialize self.
        
        self.mapView = myMapView;
        
        // Add an UIView on top of the mapView
        _canvas = [[UIView alloc] initWithFrame:
                   CGRectMake(0, 0,
                _mapView.frame.size.width, _mapView.frame.size.height)];
        
        _canvas.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        _canvas.opaque = NO;
        
        [_mapView addSubview: _canvas];
    }
    return self;
}

// Initialize common parts among all display types
- (void) initializeCommon {

    // Initialize the timer
    float timer_interval = 0.06;

    
    iv_updateUITimer = [NSTimer timerWithTimeInterval:timer_interval
                                             target:self
                                           selector:@selector(timerFired)
                                           userInfo:nil
                                            repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:iv_updateUITimer forMode:NSRunLoopCommonModes];
}


//----------------
// updates
//----------------
-(void)vcTimerFired{
    
    // if displaySet is not empty, update the map    
    if ([self.displaySet count] > 0){
        
    }
    
}



@end
