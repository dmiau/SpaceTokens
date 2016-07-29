//
//  customMKMapView.m
//  SpaceBar
//
//  Created by Daniel on 7/4/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "customMKMapView.h"
#include <stdlib.h>
#import "WildcardGestureRecognizer.h"

@implementation customMKMapView{
    NSTimer *_updateUITimer;
    struct {
        unsigned int regionDidChangeAnimated:1;
        unsigned int mapTouchBegin:1;
        unsigned int mapTouchEnded:1;
    } _delegateRespondsTo;
}

@synthesize delegate; // this is necessary so the setter could work

#pragma mark --initialization--
- (id) initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self){
        
        // additional initialization
        
        _hiddenMap = [[MKMapView alloc] initWithFrame:frame];
        _hiddenMap.mapType = MKMapTypeStandard;
        
        // this function is to check wheter the map has been touched
        float timer_interval = 0.06;
        _updateUITimer = [NSTimer timerWithTimeInterval:timer_interval
                                                 target:self
                                               selector:@selector(vcTimerFired)
                                               userInfo:nil
                                                repeats:YES];
        
        [[NSRunLoop mainRunLoop] addTimer:_updateUITimer forMode:NSRunLoopCommonModes];
        
        WildcardGestureRecognizer * tapInterceptor = [[WildcardGestureRecognizer alloc] init];
        
        tapInterceptor.touchesBeganCallback = ^(NSSet<UITouch*>* touches, UIEvent * event) {
            [self customTouchesBegan:touches withEvent:event];
        };
        
        tapInterceptor.touchesEndedCallback = ^(NSSet<UITouch*>* touches, UIEvent * event) {
            [self customTouchesEnded:touches withEvent:event];
        };

        tapInterceptor.touchesMovedCallback = ^(NSSet<UITouch*>* touches, UIEvent * event) {
            [self customTouchesMoved:touches withEvent:event];
        };
        
        tapInterceptor.delegate = self;
        [self addGestureRecognizer:tapInterceptor];
    }
    return self;
}

// Check if the protocol methods are implemetned
- (void)setDelegate:(id<MKMapViewDelegate>)aDelegate{
    if (delegate != aDelegate) {
        delegate = aDelegate;
        super.delegate = aDelegate;
        _delegateRespondsTo.regionDidChangeAnimated =
        [delegate respondsToSelector:@selector(mapView: regionDidChangeAnimated:)];
        _delegateRespondsTo.mapTouchBegin =
        [delegate respondsToSelector:@selector(mapTouchBegin: atXY:)];
        _delegateRespondsTo.mapTouchEnded =
        [delegate respondsToSelector:@selector(mapTouchEnded)];
    }
}


#pragma mark --gesture recognizer--
// this makes sure all UIControls are still functional
// http://stackoverflow.com/questions/5222998/uigesturerecognizer-blocks-subview-for-handling-touch-events?rq=1
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch{
    
    if ([[touch view] isKindOfClass:[UIControl class]]){
        return false;
    }else{
        return true;
    }
}


-(void)customTouchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    // Only handle single touch
    if ([touches count]==1){
        UITouch* aTouch = (UITouch*) [touches anyObject];
        CGPoint point = [aTouch locationInView:self];
        
        CLLocationCoordinate2D coord = [self convertPoint:point
                                     toCoordinateFromView:self];
        
        [self.delegate mapTouchBegan: coord atXY: point];
    }
//    NSLog(@"touch begins");
}

-(void)customTouchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    // Only handle single touch
    if ([touches count]==1){
        UITouch* aTouch = (UITouch*) [touches anyObject];
        CGPoint point = [aTouch locationInView:self];
        
        CLLocationCoordinate2D coord = [self convertPoint:point
                                     toCoordinateFromView:self];
        
        [self.delegate mapTouchMoved: coord atXY: point];
    }
}

-(void)customTouchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.delegate mapTouchEnded];
//    NSLog(@"touch ended");
}

//-(void)customTouchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
////    [self.delegate mapTouchEnded];
//    NSLog(@"touch canceled");
//}

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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
