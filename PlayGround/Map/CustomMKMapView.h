//
//  CustomMKMapView.h
//  SpaceBar
//
//  Created by Daniel on 7/4/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "POI.h"

// Forward declration
@class Route;

//----------------
// CustomMKMapViewDelegate
//----------------
@protocol CustomMKMapViewDelegate <NSObject>

// The following are to support the anchor+x interactions
- (void) mapTouchBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void) mapTouchMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void) mapTouchEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
@end

//----------------
// CustomMKMapView
//----------------
@interface CustomMKMapView : MKMapView{
    CustomMKMapView *hiddenMap; // for calculations
}

+ (id)sharedManager; // Singleton method

@property (nonatomic, weak) id<MKMapViewDelegate, CustomMKMapViewDelegate> delegate;
@property MKUserLocation *customUserLocation;

//@property

@property UIEdgeInsets edgeInsets;// this is for the zoom-to-fit feature

@property BOOL isDebugModeOn;

//=====================
- (void)updateHiddenMap;

// === (MapDisplay) ===
// Two snapping methods
- (void) snapOneCoordinate: (CLLocationCoordinate2D) coord toXY: (CGPoint) viewXY
                  animated: (BOOL) flag;
- (void) snapOneCoordinate: (CLLocationCoordinate2D) coord toXY: (CGPoint) viewXY
           withOrientation: (float) orientation
                  animated: (BOOL) flag;
- (void) snapTwoCoordinates: (CLLocationCoordinate2D[2]) coords
                    toTwoXY: (CGPoint[2]) viewXYs;

- (void) zoomToFitPOIs: (NSSet<POI*> *) poiSet;
- (void) zoomToFitRoute:(Route*) aRoute;

// Tools
+ (CLLocationDirection) computeOrientationFromA: (CLLocationCoordinate2D) coordA
                                            toB: (CLLocationCoordinate2D) coordB;

+ (MKMapRect)MKMapRectForCoordinateRegion:(MKCoordinateRegion)region;

@end
