//
//  SpaceBar.h
//  PlayGround
//
//  Created by Daniel on 2/1/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Map/customMKMapView.h"
#import "SpaceToken.h"
#import "RangeSlider/CERangeSlider.h"


@class Route;

#pragma mark - SpaceBarProtocol
//----------------------------
// SpaceBar (delegate)
//----------------------------
@protocol SpaceBarDelegate <NSObject>

// SpaceToken delegate methods


// SpaceBar delegate methods
- (void)spaceBarOnePointTouched:(float) percentage;
- (void)spaceBarTwoPointsTouchedLow:(float) low high: (float) high;
- (void)spaceBarElevatorMovedLow:(float) low high: (float) high fromLowToHigh: (bool) flag;
@end

#pragma mark - SpaceBarInterface
//----------------------------
// SpaceBar
//----------------------------
@interface SpaceBar : NSObject <CERangeSliderDelegate>
@property (nonatomic, weak) id <SpaceBarDelegate> delegate;
@property (weak) customMKMapView *mapView;
@property CERangeSlider* sliderContainer;
@property bool smallValueOnTopOfBar; //by default the small value is on top, user can use this flag to flip the default behavior

// This is a convenient set to cache the references to all the
// POIs on the track
@property NSMutableSet <SpaceToken*> *buttonSet;
@property NSMutableSet <SpaceToken*> *dotSet;

// This is a convenient set to cache the references of all the
// POIs that are being touched.
@property NSMutableSet <SpaceToken*> *touchingSet;

// This is a convenient set to cache the references of all the
// POIs that are being dragged
@property NSMutableSet <SpaceToken*> *draggingSet;

// Some special POIs are cached in SpaceBar
@property SpaceToken* mapCentroid;
@property SpaceToken* youAreHere;
@property SpaceToken* anchor;

@property NSTimer *privateTouchingSetTimer;
// timer for touchingSet

// Use bit field to track if delegate is set properly
//http://www.ios-blog.co.uk/tutorials/objective-c/how-to-create-an-objective-c-delegate/
@property  struct {
unsigned int spaceBarOnePointTouched:1;
unsigned int spaceBarTwoPointsTouched:1;
unsigned int spaceBarElevatorMoved:1;
} delegateRespondsTo;

// Constructors
- (id)initWithMapView: (MKMapView *) myMapView;

- (SpaceToken*) addSpaceTokenWithName: (NSString*) name
                             LatLon: (CLLocationCoordinate2D) latlon;
- (void)addSpaceTokensFromPOIArray: (NSArray <POI*> *) poiArray;
- (void)removeAllSpaceTokens;
- (void)resetSpaceBar;
- (void)clearAllTouchedTokens;

// --------------
// Implemented in annotation category
// --------------
- (void) addAnnotationsFromRoute:(Route *) route;


// --------------
// Implemented in Interactions category
// --------------
- (void) updateElevatorFromPercentagePair: (float[2]) percentagePair;
- (void) addAnchorForCoordinates: (CLLocationCoordinate2D) coord atMapXY: (CGPoint) mapXY;
- (void) updateAnchorAtMapXY: (CGPoint) mapXY;
- (void) removeAnchor;

// --------------
// Implemented in updateSet category
// --------------
- (void) updateSpecialPOIs;
- (void) orderPOIs;
- (void) addToSetBasedOnNotification: (NSNotification*) aNotification;
- (void) removeFromSetBasedOnNotification: (NSNotification*) aNotification;

// --------------
// Implemented in updateMap category
// --------------

// copy the button centroid to the dragged button's mapXY
- (void) fillDraggingMapXYs;

// update the (x, y) coordinates for each POI in the set
- (void) fillMapXYsForSet: (NSSet*) aSet;


- (void) zoomMapToFitTouchSet;
- (void) updateMapToFitPOIPreferences: (NSMutableSet*) poiSet;

@end
