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
@property NSString *name;
@property CustomPointAnnotation *annotation;
@end
