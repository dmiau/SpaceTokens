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
@interface POI : UIButton


//---properties
@property CLLocationCoordinate2D latLon;
@property CGPoint mapViewXY;

//---methods
- (id) initPOI;
- (void) resetButton;

@end
