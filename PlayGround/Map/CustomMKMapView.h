//
//  CustomMKMapView.h
//  SpaceBar
//
//  Created by Daniel on 7/4/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <MapKit/MapKit.h>

// Forward declration
@class SpatialEntity;
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

//==============================
// CustomMKMapView
//==============================
@interface CustomMKMapView : MKMapView{
    MKMapView *hiddenMap; // for calculations
    
    struct {
        unsigned int regionDidChangeAnimated:1;
        unsigned int mapTouchBegin:1;
        unsigned int mapTouchMoved:1;
        unsigned int mapTouchEnded:1;
    } _delegateRespondsTo;
    
}

+ (id)sharedManager; // Singleton method

@property (nonatomic, weak) id<MKMapViewDelegate, CustomMKMapViewDelegate> delegate;
@property MKUserLocation *customUserLocation;

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

- (void) zoomToFitEntities: (NSSet<SpatialEntity*> *) entitySet;
- (void) zoomToFitRoute:(Route*) aRoute;

// Tools
+ (CLLocationDirection) computeOrientationFromA: (CLLocationCoordinate2D) coordA
                                            toB: (CLLocationCoordinate2D) coordB;

+ (MKMapRect)MKMapRectForCoordinateRegion:(MKCoordinateRegion)region;


//==============================
// Private Methods
//==============================
- (void)p_initGestureRecognizer;

@end
