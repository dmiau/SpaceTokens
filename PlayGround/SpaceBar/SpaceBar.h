//
//  SpaceBar.h
//  PlayGround
//
//  Created by Daniel on 2/1/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface SpaceBar : NSObject

@property UIView *canvas;
@property (weak) MKMapView *mapView;

@property NSMutableArray *POIArray;
@property NSMutableArray *SpaceMarkArray;

@property NSMutableSet *displaySet;

// Constructors
- (id)initWithMapView: (MKMapView *) myMapView;

@end
