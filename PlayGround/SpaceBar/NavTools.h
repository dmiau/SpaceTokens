//
//  NavTools.h
//  PlayGround
//
//  Created by Daniel on 2/1/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomMKMapView.h"
#import "SpaceToken.h"
#import "RangeSlider/PathBar.h"
#import "TokenCollection.h"

@class Route;
@class GestureEngine;
@class TokenCollectionView;
@class ArrayTool;



#pragma mark - SpaceBarInterface
typedef enum {TOKENONLY, PATH} SpaceBarMode;

//--------------------------------------------------------
// SpaceBar
//--------------------------------------------------------
@interface NavTools : NSObject <PathBarDelegate>

@property BOOL isBarToolHidden;
@property BOOL isStudyModeEnabled;
@property SpaceBarMode spaceBarMode;
@property CGRect frame;
@property (weak) CustomMKMapView *mapView;

@property TokenCollectionView *tokenCollectionView;
@property TokenCollection *tokenCollection;

@property PathBar* sliderContainer;
@property GestureEngine *gestureEngine;


// Cache the active route object
@property Route* activeRoute;


// This is a convenient set to cache the references of all the
// POIs that are being touched.
@property NSMutableSet <SpaceToken*> *touchingSet;

// This is a convenient set to cache the references of all the
// POIs that are being dragged
@property NSMutableSet <SpaceToken*> *draggingSet;

@property BOOL isConstrainEngineON;
@property BOOL isAutoOrderSpaceTokenEnabled;
@property BOOL isSpaceTokenEnabled; // Wildcard gesture recognizer is used when this mode is on (so the behavior of interacting with the map will be a big different)
@property BOOL isAnchorAllowed;
@property NSMutableSet <SpaceToken*> *anchorCandidateSet;
@property NSMutableSet <SpaceToken*> *anchorSet;
@property NSMutableArray *anchorTouchInfoArray; // a structure to detect whether an anchor touch is a tap

@property BOOL isMultipleTokenSelectionEnabled;


+ (NavTools*)sharedManager;

// Constructors
- (id)initWithMapView: (CustomMKMapView *) myMapView;

// --------------
// SpaceToken management
// --------------
- (void)resetInteractiveTokenStructures; // Clears draggingSet, anchors, and touchingSet
- (void)removeAllSpaceTokens;
- (void)resetSpaceBar;
- (void)clearAllTouchedTokens;

// --------------
// Constraint engine
// --------------
- (void)updateBasedOnConstraints;




// --------------
// Implemented in Interactions category
// --------------

- (void) addAnchorForTouches:(NSSet<UITouch *> *)touches;
- (void) updateAnchorForTouches: (NSSet<UITouch *> *)touches;
- (void) removeAnchorForTouches: (NSSet<UITouch *> *)touches;
- (void) removeAllAnchors;

// --------------
// Implemented in updateSet category
// --------------
//- (void) orderButtonArray;
- (void) addToSetBasedOnNotification: (NSNotification*) aNotification;
- (void) removeFromSetBasedOnNotification: (NSNotification*) aNotification;

// --------------
// Implemented in updateMap category
// --------------

// copy the button centroid to the dragged button's mapXY
- (void) fillDraggingMapXYs;

- (void) zoomMapToFitTouchSet;
- (void) updateMapToFitPOIPreferences: (NSMutableSet*) poiSet;

@end
