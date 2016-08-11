//
//  POI.h
//  SpaceBar
//
//  Created by Daniel on 2/1/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>



//-------------------
// POI
//-------------------
@interface POI : NSObject

//---properties
@property CLLocationCoordinate2D latLon;
@property MKCoordinateSpan coordSpan;

// mapViewXY caches the Mercator (x, y) coordinates
// corrresponding to latlon
@property CGPoint mapViewXY;
@property NSString *name;

@end
