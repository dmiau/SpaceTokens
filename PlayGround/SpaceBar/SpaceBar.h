//
//  SpaceBar.h
//  PlayGround
//
//  Created by Daniel on 2/1/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Map/CustomMKMapView.h"
#import "SpaceToken.h"
#import "RangeSlider/CERangeSlider.h"
#import "TokenCollection.h"

@class Route;
@class GestureEngine;

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
typedef enum {TOKENONLY, PATH} SpaceBarMode;

//----------------------------
// SpaceBar
//----------------------------
@interface SpaceBar : NSObject <CERangeSliderDelegate>
@property SpaceBarMode spaceBarMode;
@property CGRect frame;
@property (nonatomic, weak) id <SpaceBarDelegate> delegate;
@property (weak) CustomMKMapView *mapView;
@property CERangeSlider* sliderContainer;
@property GestureEngine *gestureEngine;

@property bool smallValueOnTopOfBar; //by default the small value is on top, user can use this flag to flip the default behavior

// Cache the active route object
@property Route* activeRoute;

@property NSMutableArray <SpatialEntity*> *entityArrayDataSource;
@property TokenCollection *tokenCollection;
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
@property BOOL isTokenDraggingEnabled; // Control whether SpaceTokens can be dragged or not
@property BOOL isConstrainEngineON;
@property BOOL isYouAreHereEnabled;
@property BOOL isAutoOrderSpaceTokenEnabled;
@property NSMutableArray <SpaceToken*> *anchorArray;

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

// --------------
// SpaceToken management
// --------------
- (SpaceToken*) addSpaceTokenFromEntity:(SpatialEntity*) spatialEntity;
- (void)addSpaceTokensFromEntityArray: (NSMutableArray <SpatialEntity*> *) entityArray;
- (void)removeAllSpaceTokens;
- (void)resetSpaceBar;
- (void)clearAllTouchedTokens;

// --------------
// Constraint engine
// --------------
- (void)updateBasedOnConstraints;


// --------------
// Implemented in annotation category
// --------------
@property UIView *annotationView;
- (void) addAnnotationsFromRoute:(Route *) route;
- (void) removeRouteAnnotations;

// --------------
// Implemented in Interactions category
// --------------
- (void) updateElevatorFromPercentagePair: (float[2]) percentagePair;
- (void) addAnchorForTouches:(NSSet<UITouch *> *)touches;
- (void) updateAnchorForTouches: (NSSet<UITouch *> *)touches;
- (void) removeAnchorForTouches: (NSSet<UITouch *> *)touches;
- (void) removeAllAnchors;
- (void) convertAnchorToRealToken: (SpaceToken*) token;

// --------------
// Implemented in updateSet category
// --------------
- (void) updateSpecialPOIs;
- (void) orderButtonArray;
- (void) addToSetBasedOnNotification: (NSNotification*) aNotification;
- (void) removeFromSetBasedOnNotification: (NSNotification*) aNotification;

// --------------
// Implemented in updateMap category
// --------------

// copy the button centroid to the dragged button's mapXY
- (void) fillDraggingMapXYs;

// update the (x, y) coordinates for each POI in the set
- (void) fillMapXYsForSet: (NSArray*) aSet;


- (void) zoomMapToFitTouchSet;
- (void) updateMapToFitPOIPreferences: (NSMutableSet*) poiSet;

@end
