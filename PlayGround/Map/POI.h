//
//  POI.h
//  SpaceBar
//
//  Created by Daniel on 2/1/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CustomPointAnnotation.h"


//-------------------
// POI
//-------------------
@interface POI : NSObject

//---properties
@property CLLocationCoordinate2D latLon;
@property MKCoordinateSpan coordSpan;
@property double headingInDegree;
@property NSString *name;
@property CustomPointAnnotation *annotation;
@property bool isEnabled;
@property (weak) id linkedObj; // a POI can be linked another object, e.g., a SpaceToken
@end
