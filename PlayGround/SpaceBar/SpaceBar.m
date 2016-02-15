//
//  SpaceBar.m
//  PlayGround
//
//  Created by Daniel on 2/1/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SpaceBar.h"
#import "Constants.h"

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
        
    }
    return self;
}

// Initialize common parts among all display types
- (void) initializeCommon {

    self.POIArray = [[NSMutableArray alloc] init];
    self.SpaceMarkArray = [[NSMutableArray alloc] init];
    
    self.displaySet = [[NSMutableSet alloc] init];
    self.touchingSet = [[NSMutableSet alloc] init];
    self.draggingSet = [[NSMutableSet alloc] init];        
    
    // listen to several notification of interest
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
        selector:@selector(addToSetBasedOnNotification:)
        name:AddToDisplaySetNotification
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
                   name:RemoveFromDisplaySetNotification
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
    // if displaySet is not empty, update the map    
    if ([self.displaySet count] > 0){
        [self orderPOIs];
    }
    
    if ([self.draggingSet count] > 0){
        [self fillDraggingMapXYs];
        [self updateMapToFitPOIs:self.draggingSet];
    }else    
        if ([self.touchingSet count] > 0){
        [self zoomMapToFitTouchSet];
    }    
}




//----------------
// order the POIs and SpaceMarks on the track
//----------------
- (void) orderPOIs{
//    // count the number of POIs on the track
//    NSPredicate *aPredicate = [NSPredicate predicateWithFormat:
//                               @"self.superview != nil"];
//    
//    NSArray *visibleSpaceMarks = [self.SpaceMarkArray filteredArrayUsingPredicate:aPredicate];
    
    //TODO: this function needs to be refactored later
    
    // equally distribute the POIs
    if ([self.displaySet count] > 0){
        CGFloat barHeight = self.mapView.frame.size.height;
        CGFloat viewWidth = self.mapView.frame.size.width;
        
        CGFloat gap = barHeight / ([self.displaySet count] + 1);
        
        int i = 0;
        for (POI *aPOI in self.displaySet){
            aPOI.frame = CGRectMake(viewWidth - aPOI.frame.size.width,
                                     gap * (i+1), aPOI.frame.size.width,
                                     aPOI.frame.size.height);
            i++;
        }
    }
}


//----------------
// desctructor
//----------------
-(void)dealloc {
    //cleanup code
    NSLog(@"Goodbye!");
}

@end
