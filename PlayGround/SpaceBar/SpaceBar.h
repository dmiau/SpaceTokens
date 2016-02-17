//
//  SpaceBar.h
//  PlayGround
//
//  Created by Daniel on 2/1/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SpaceMark.h"

@interface SpaceBar : NSObject

//@property UIView *ca nvas;
@property (weak) MKMapView *mapView;

@property UIView *canvas;

@property NSMutableArray *POIArray;
@property NSMutableArray *SpaceMarkArray;

// This is a convenient set to cache the references to all the
// POIs on the track
@property NSMutableSet *displaySet;

// This is a convenient set to cache the references to all the
// POIs that are being touched.
@property NSMutableSet *touchingSet;

// This is a convenient set to cache the references to all the
// POIs that are being dragged
@property NSMutableSet *draggingSet;

// Constructors
- (id)initWithMapView: (MKMapView *) myMapView;

- (SpaceMark*) addSpaceMarkWithName: (NSString*) name
                             LatLon: (CLLocationCoordinate2D) latlon;
// --------------
// Private methods
// --------------
- (void) orderPOIs;


// --------------
// Implement in updateSet category
// --------------

- (void) addToSetBasedOnNotification: (NSNotification*) aNotification;
- (void) removeFromSetBasedOnNotification: (NSNotification*) aNotification;

// --------------
// Implement in updateMap category
// --------------
- (void) fillDraggingMapXYs;
- (void) zoomMapToFitTouchSet;
- (void) updateMapToFitPOIs: (NSMutableSet*) poiSet;

@end
