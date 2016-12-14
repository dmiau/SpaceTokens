//
//  SpatialEntity.h
//  SpaceBar
//
//  Created by Daniel on 11/11/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CustomPointAnnotation.h"

@interface SpatialEntity : NSObject

// MARK: Properties

@property NSString *name;
@property NSString *tag;
@property CustomPointAnnotation *annotation;

// Did not use MKCoordinateRegion because I want to use
// custom setter for latLon to update the annotation object
@property CLLocationCoordinate2D latLon;
@property MKCoordinateSpan coordSpan;


@property BOOL isEnabled; // Whether this entity is enabled or not
@property BOOL isMapAnnotationEnabled;
@property (weak) id linkedObj; // a POI can be linked another object,

@property BOOL isHackTokenSelected;
// a hack to cache the token selection status, since scrolling a collection view erases the token selection status

// MARK: Methods
- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;

@end
