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
#import "SpatialEntity.h"

//-------------------
// POI
//-------------------
@interface POI : SpatialEntity

@property CustomPointAnnotation *annotation;

@end
