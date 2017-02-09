//
//  SpatialEntity.h
//  SpaceBar
//
//  Created by Daniel on 11/11/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomMKMapView.h"
#import "AnnotationProtocol.h"

@interface SpatialEntity : NSObject

// MARK: Properties

@property NSString *name;
@property NSString *tag;
@property id <AnnotationProtocol> annotation;

// Did not use MKCoordinateRegion because I want to use
// custom setter for latLon to update the annotation object
@property CLLocationCoordinate2D latLon;
@property MKCoordinateSpan coordSpan;
@property NSString *placeID;

@property BOOL isEnabled; // Whether this entity is enabled or not
@property BOOL isMapAnnotationEnabled;
@property (weak) id linkedObj; // a POI can be linked another object,


// MARK: Methods
-(BOOL)checkVisibilityOnMap:(CustomMKMapView*) mapView;

// This is to control the annotation of a map other than the regular map
- (void)setMapAnnotationEnabled:(BOOL)flag onMap:(CustomMKMapView*)map;

- (double)getPointDistanceToTouch:(UITouch*)touch;


- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;

@end
