//
//  CustomMKMapView.m
//  SpaceBar
//
//  Created by Daniel on 7/4/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "CustomMKMapView.h"
#include <stdlib.h>


@implementation CustomMKMapView{
    NSTimer *_updateUITimer;

}

@synthesize delegate; // this is necessary so the setter could work

#pragma mark --initialization--

// Two initialization methods

//http://www.galloway.me.uk/tutorials/singleton-classes/

+ (id)sharedManager {
    static CustomMKMapView *sharedCustomMKMapView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCustomMKMapView = [[CustomMKMapView alloc] init];
        // init will call initWithFrame
//        [sharedCustomMKMapView commonInit];
    });
    return sharedCustomMKMapView;
}

- (id) initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self){
        [self commonInit];

    }
    return self;
}

- (void)commonInit{    
    // Initialize the custom user location
    _customUserLocation = [[MKUserLocation alloc] init];
    self.edgeInsets = UIEdgeInsetsMake(10, 10, 10, 70);
    self.isDebugModeOn = YES;
    
    //-----------------
    // Initialize a hidden map
    //-----------------
    hiddenMap = [[MKMapView alloc] init];
    hiddenMap.translatesAutoresizingMaskIntoConstraints = NO;
    hiddenMap.mapType = MKMapTypeStandard;
    [self addSubview:hiddenMap];
    [hiddenMap setUserInteractionEnabled:NO];
//    [hiddenMap setAlpha:0.5];
    [hiddenMap setHidden:YES];
    // Use constraint to make sure the hidden map is the same size as the acutal map
    


    //-----------------
    // Constraints
    //-----------------
    NSMutableDictionary *viewDictionary = [[NSMutableDictionary alloc] init];
    viewDictionary[@"hiddenMap"] = hiddenMap;
    viewDictionary[@"realMap"] = self;
    
    NSMutableArray *constraintStringArray = [[NSMutableArray alloc] init];
    [constraintStringArray addObject:@"H:[hiddenMap(==realMap)]"];
    [constraintStringArray addObject:@"V:[hiddenMap(==realMap)]"];
    [constraintStringArray addObject:@"V:|-0-[hiddenMap]-0-|"];
    [constraintStringArray addObject:@"H:|-0-[hiddenMap]-0-|"];
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    for (NSString *constraintString in constraintStringArray){
        [constraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:constraintString
                                                 options:0 metrics:nil
                                                   views:viewDictionary]];
    }
    
    [self addConstraints:constraints];
    
    //----------------------
    // initialize the timer
    //----------------------
    // this function is to check wheter the map has been touched
    float timer_interval = 0.06;
    _updateUITimer = [NSTimer timerWithTimeInterval:timer_interval
                                             target:self
                                           selector:@selector(vcTimerFired)
                                           userInfo:nil
                                            repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:_updateUITimer forMode:NSRunLoopCommonModes];

    //----------------------
    // initialize the gesture recognizer
    //----------------------
    [self p_initGestureRecognizer];

}

// Check if the protocol methods are implemetned
- (void)setDelegate:(id<MKMapViewDelegate>)aDelegate{
    if (delegate != aDelegate) {
        delegate = aDelegate;
        super.delegate = aDelegate;
        _delegateRespondsTo.regionDidChangeAnimated =
        [delegate respondsToSelector:@selector(mapView: regionDidChangeAnimated:)];
        _delegateRespondsTo.mapTouchBegin =
        [delegate respondsToSelector:@selector(mapTouchBegan: withEvent:)];
        _delegateRespondsTo.mapTouchMoved =
        [delegate respondsToSelector:@selector(mapTouchMoved: withEvent:)];
        _delegateRespondsTo.mapTouchEnded =
        [delegate respondsToSelector:@selector(mapTouchEnded: withEvent:)];
    }
}

#pragma mark --timer--
-(void)vcTimerFired{
    
    static double latitude_cache = 0.0;
    static double longitude_cache = 0.0;
    static double pitch_cache = 0.0;
    static double camera_heading = 0.0;
    static bool   hasChanged = false;
    double epsilon = 0.0000001;
    
    // Note that heading is defined as the negative of
    // _mapView.camera.heading
    if ( fabs((double)(latitude_cache - [self centerCoordinate].latitude)) > epsilon ||
        fabs((double)(longitude_cache - [self centerCoordinate].longitude)) > epsilon ||
        fabs((double)(pitch_cache - self.camera.pitch)) > epsilon||
        fabs((double)(camera_heading - [self calculateCameraHeading])) > epsilon)
    {
        latitude_cache = [self centerCoordinate].latitude;
        longitude_cache = [self centerCoordinate].longitude;
        pitch_cache = self.camera.pitch;
        camera_heading = [self calculateCameraHeading];
        
        
        if(_delegateRespondsTo.regionDidChangeAnimated){
            [self.delegate mapView:self regionDidChangeAnimated:YES];
        }
        
        hasChanged = true;
    }else{
        // This condition is reached when the map comes to a stop
        // Do a force refresh
        if (hasChanged){
            // Do a force refresh
            if(_delegateRespondsTo.regionDidChangeAnimated){
                [self.delegate mapView:self regionDidChangeAnimated:YES];
            }
            hasChanged = false;
        }
    }

    //    NSLog(@"*****tableCellCache size %lu", (unsigned long)[tableCellCache count]);
}


- (float) calculateCameraHeading{
    // calculateCameraHeading calculates the heading of camera relative to
    // the magnetic north
    
    // heading calculation is tricky; it does not work well in satelliteflyover
    // the camera heading is counterclockwise, 0 is the top
    
    float true_north_wrt_up = 0;
    double width = self.frame.size.width;
    double height = self.frame.size.height;
    
    //    CLLocationCoordinate2D map_s_pt = [self.mapView centerCoordinate];
    CLLocationCoordinate2D map_s_pt = [self
                                       convertPoint:CGPointMake(width/2, height-20) toCoordinateFromView:self];
    CLLocationCoordinate2D map_n_pt = [self convertPoint:CGPointMake(width/2, 20) toCoordinateFromView:self];
    
    true_north_wrt_up = computeOrientationFromA2B(map_s_pt, map_n_pt);
    
    return true_north_wrt_up;
}


double RadiansToDegrees(double radians) {return radians * 180.0/M_PI;};

double computeOrientationFromA2B
(CLLocationCoordinate2D A, CLLocationCoordinate2D B)
{
    MKMapPoint ref_mappoint = MKMapPointForCoordinate(A);
    
    MKMapPoint measured_mappoint = MKMapPointForCoordinate(B);
    
    double radiansBearing = atan2(measured_mappoint.x - ref_mappoint.x,
                                  -(measured_mappoint.y - ref_mappoint.y));
    
    double degree = RadiansToDegrees(radiansBearing);
    
    // This guarantees that the orientaiton is always positive
    if (degree < 0) degree += 360;
    return degree;
}

- (void)updateHiddenMap{
    
    // Calculate the scale
    
    // Get two map points from the real map and computer their graphics distance
    MKMapRect mapRect = self.visibleMapRect;
    MKMapPoint mapPointA = MKMapPointMake(mapRect.origin.x
                                         , mapRect.origin.y +
                                         mapRect.size.height/2);
    MKMapPoint mapPointB = MKMapPointMake(mapRect.origin.x + mapRect.size.width
                                          , mapRect.origin.y +
                                          mapRect.size.height/2);
    
    // Calculate the corresponding CGPoints
    CGPoint cgPointA =  [self convertCoordinate:MKCoordinateForMapPoint(mapPointA) toPointToView:self];
    CGPoint cgPointB =  [self convertCoordinate:MKCoordinateForMapPoint(mapPointB) toPointToView:self];
    
    // Compute the cg distance
    double distOnRealMap = sqrt(pow(cgPointA.x - cgPointB.x, 2) +
                                pow(cgPointA.y - cgPointB.x, 2));
    
    cgPointA =  [hiddenMap convertCoordinate:MKCoordinateForMapPoint(mapPointA) toPointToView:hiddenMap];
    cgPointB =  [hiddenMap convertCoordinate:MKCoordinateForMapPoint(mapPointB) toPointToView:hiddenMap];
    double distOnHiddenMap = sqrt(pow(cgPointA.x - cgPointB.x, 2) +
                                  pow(cgPointA.y - cgPointB.x, 2));
    
    double scale = distOnHiddenMap / distOnRealMap;
    
    // Scale the hiddenMap
    hiddenMap.camera.heading = 0;
    
    MKMapRect hiddenRect = hiddenMap.visibleMapRect;
    hiddenMap.visibleMapRect = MKMapRectMake(mapRect.origin.x, mapRect.origin.y, hiddenRect.size.width * scale, hiddenRect.size.height*scale);
    
    // Set the
    hiddenMap.camera.heading = self.camera.heading;
    
    // Set the centroid
    hiddenMap.centerCoordinate = self.centerCoordinate;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
@end
