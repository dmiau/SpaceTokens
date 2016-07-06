//
//  SpaceBar.h
//  PlayGround
//
//  Created by Daniel on 2/1/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SpaceToken.h"
#import "RangeSlider/CERangeSlider.h"

#pragma mark - SpaceBarProtocol
//----------------------------
// SpaceBar (delegate)
//----------------------------
@protocol SpaceBarDelegate <NSObject>
- (void)spaceBarOnePointTouched:(float) percentage;
- (void)spaceBarTwoPointsTouched:(float[2]) percentagePair;
@end

#pragma mark - SpaceBarInterface
//----------------------------
// SpaceBar
//----------------------------
@interface SpaceBar : NSObject <CERangeSliderDelegate>
@property (nonatomic, weak) id <SpaceBarDelegate> delegate;
//@property UIView *ca nvas;
@property (weak) MKMapView *mapView;

//@property UIView *canvas;
@property CERangeSlider* rangeSlider;

@property NSMutableArray *SpaceTokenArray;

// This is a convenient set to cache the references to all the
// POIs on the track
@property NSMutableSet *buttonSet;

@property NSMutableSet *dotSet;

// This is a convenient set to cache the references of all the
// POIs that are being touched.
@property NSMutableSet *touchingSet;

// This is a convenient set to cache the references of all the
// POIs that are being dragged
@property NSMutableSet *draggingSet;

// Two special POIs are cached in SpaceBar
@property POI* mapCentroid;
@property POI* youAreHere;


// Use bit field to track if delegate is set properly
//http://www.ios-blog.co.uk/tutorials/objective-c/how-to-create-an-objective-c-delegate/
@property  struct {
unsigned int spaceBarOnePointTouched:1;
unsigned int spaceBarTwoPointsTouched:1;
} delegateRespondsTo;

// Constructors
- (id)initWithMapView: (MKMapView *) myMapView;

- (SpaceToken*) addSpaceTokenWithName: (NSString*) name
                             LatLon: (CLLocationCoordinate2D) latlon;
// --------------
// Implement in Interactions category
// --------------
- (void) updateElevatorFromPercentagePair: (float[2]) percentagePair;

// --------------
// Implement in updateSet category
// --------------
- (void) updateSpecialPOIs;
- (void) orderPOIs;
- (void) addToSetBasedOnNotification: (NSNotification*) aNotification;
- (void) removeFromSetBasedOnNotification: (NSNotification*) aNotification;

// --------------
// Implement in updateMap category
// --------------

// copy the button centroid to the dragged button's mapXY
- (void) fillDraggingMapXYs;

// update the (x, y) coordinates for each POI in the set
- (void) fillMapXYsForSet: (NSSet*) aSet;
- (void) zoomMapToFitTouchSet;
- (void) updateMapToFitPOIPreferences: (NSMutableSet*) poiSet;

@end
