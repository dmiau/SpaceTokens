//
//  SpaceBar.m
//  PlayGround
//
//  Created by Daniel on 2/1/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SpaceBar.h"
#import "Constants.h"
#import "CERangeSlider.h"

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
        // This part is common for all display types
        [self initializeCommon];
        

        // Initialize the map
        self.mapView = myMapView;    
        
//        // Add an UIView on top of the mapView
//        _canvas = [[UIView alloc] initWithFrame:
//                   CGRectMake(0, 0,
//                _mapView.frame.size.width, _mapView.frame.size.height)];
//        
//        _canvas.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
//        _canvas.opaque = NO;
//
//        [_mapView addSubview: _canvas];
        
        // Add the range track
        CGRect sliderFrame = CGRectMake(self.mapView.frame.size.width - 30, 0,
                                        30,
                                        self.mapView.frame.size.height);
        
        self.sliderContainer = [[CERangeSlider alloc] initWithFrame:sliderFrame];
        self.sliderContainer.delegate = self;
        self.sliderContainer.trackPaddingInPoints = 30;

        [self.mapView addSubview:self.sliderContainer];
        
//        [self.sliderContainer addTarget:self
//                         action:@selector(slideValueChanged:)
//               forControlEvents:UIControlEventValueChanged];
        self.sliderContainer.curvatiousness = 0.0;
        
    }
    return self;
}


- (void)setDelegate:(id <SpaceBarDelegate>)aDelegate {
    if (_delegate != aDelegate) {
        _delegate = aDelegate;
        
        _delegateRespondsTo.spaceBarOnePointTouched =
        [_delegate respondsToSelector:@selector(spaceBarOnePointTouched:)];
        _delegateRespondsTo.spaceBarTwoPointsTouched =
        [_delegate respondsToSelector:@selector(spaceBarTwoPointsTouchedLow:high:)];
    }
}

// Initialize common parts among all display types
- (void) initializeCommon {
    
    self.buttonSet = [[NSMutableSet alloc] init];
    self.dotSet = [[NSMutableSet alloc] init];
    
    self.touchingSet = [[NSMutableSet alloc] init];
    self.draggingSet = [[NSMutableSet alloc] init];        
    
    self.mapCentroid = [[SpaceToken alloc] initForType:DOT];    
    [self.dotSet addObject:self.mapCentroid];
    
    self.smallValueOnTopOfBar = true;
    
    // listen to several notification of interest
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
        selector:@selector(addToSetBasedOnNotification:)
        name:AddToButtonSetNotification
        object:[[ UIApplication sharedApplication] delegate]];

    [center addObserver:self
               selector:@selector(addToSetBasedOnNotification:)
                   name:AddToTouchingSetNotification
                 object:nil];
    //[[ UIApplication sharedApplication] delegate]
    
    [center addObserver:self
               selector:@selector(addToSetBasedOnNotification:)
                   name:AddToDraggingSetNotification
                 object:nil];
    

    [center addObserver:self
               selector:@selector(removeFromSetBasedOnNotification:)
                   name:RemoveFromButtonSetNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(removeFromSetBasedOnNotification:)
                   name:RemoveFromTouchingSetNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(removeFromSetBasedOnNotification:)
                   name:RemoveFromDraggingSetNotification
                 object:nil];
        
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
// timer
//----------------
-(void)timerFired{    
    // if buttonSet is not empty, update the map    
    if ([self.buttonSet count] > 0){
        [self orderPOIs];
    }
    
    if ([self.draggingSet count] > 0){
        [self fillDraggingMapXYs];
        [self updateMapToFitPOIPreferences:self.draggingSet];
    }else    
        if ([self.touchingSet count] > 0){
        [self zoomMapToFitTouchSet];
    }    
}

- (void) resetSpaceBar{
    // The valid range of lowerValue and upperValue of the elevator should be [0, 1]
    // Setting the lowerValue and upperValue to be both -1 will make the elevator invisible
    float temp[2] = {-1, -1};
    [self updateElevatorFromPercentagePair:temp];
}


//----------------
// desctructor
//----------------
-(void)dealloc {
    //cleanup code
    NSLog(@"Goodbye!");
}

@end
