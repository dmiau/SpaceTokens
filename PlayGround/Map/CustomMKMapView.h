//
//  CustomMKMapView.h
//  SpaceBar
//
//  Created by Daniel on 7/4/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <GoogleMaps/GoogleMaps.h>


// Forward declration
@class SpatialEntity;
@class Route;
@class InformationSheetManager;

//==============================
// CustomMKMapView ******Delegate
//==============================
@protocol CustomMKMapViewDelegate <NSObject>

// The following are to support the anchor+x interactions
- (void) mapTouchBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void) mapTouchMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void) mapTouchEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;

@end


//==============================
// CustomMKMapView
//==============================
@interface CustomMKMapView : GMSMapView{
    
    struct {
        unsigned int mapTouchBegin:1;
        unsigned int mapTouchMoved:1;
        unsigned int mapTouchEnded:1;
    } _delegateRespondsTo;
    
}

+ (CustomMKMapView*)sharedManager; // Singleton method

@property (nonatomic, weak) id<CustomMKMapViewDelegate, GMSMapViewDelegate> delegate;


@property UIEdgeInsets edgeInsets;// this is for the zoom-to-fit feature

@property BOOL isLongPressEnabled;

@property BOOL isDebugModeOn;
@property InformationSheetManager *informationSheetManager;

- (void)refreshAnnotations;

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

// Tools
+ (CLLocationDirection) computeOrientationFromA: (CLLocationCoordinate2D) coordA
                                            toB: (CLLocationCoordinate2D) coordB;

+ (MKMapRect)MKMapRectForCoordinateRegion:(MKCoordinateRegion)region;
+ (BOOL) validateCoordinate:(CLLocationCoordinate2D) coord;

//==============================
// Private Methods
//==============================
- (void)p_initGestureRecognizer;


//==============================
// Methods for porting to GMSMapView
//==============================
-(CGPoint)convertCoordinate:(CLLocationCoordinate2D)coordinate toPointToView:(UIView *)view;
-(CLLocationCoordinate2D)convertPoint:(CGPoint)point toCoordinateFromView:(UIView *)view;
- (void)addOverlay:(id<MKOverlay>)overlay;
- (void)removeOverlay:(id<MKOverlay>)overlay;
@property MKCoordinateRegion region;
@property MKMapRect visibleMapRect;
- (void)setVisibleMapRect:(MKMapRect)mapRect edgePadding:(UIEdgeInsets)insets animated:(BOOL)animate;
- (void)addAnnotation:(id<MKAnnotation>)annotation;
- (void)removeAnnotation:(id<MKAnnotation>)annotation;

// Convenient update methods
-(void)updateZoom:(float)newZoom;
-(void)updateBearing:(float)newBearing;
-(void)updateCenterCoordinates:(CLLocationCoordinate2D)newCoord;

-(BOOL)containsCoordinate:(CLLocationCoordinate2D)newCoord;

@end
