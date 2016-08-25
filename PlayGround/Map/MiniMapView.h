//
//  MiniMapView.h
//  SpaceBar
//
//  Created by Daniel on 8/11/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "customMKMapView.h"

@interface MiniMapView : customMKMapView <MKMapViewDelegate, customMKMapViewDelegate>

@property MKPolyline *boxPolyline;
@property BOOL syncRotation;

- (void) updateBox: (MKMapView*) aMapView;
- (void) removeRouteOverlays;
@end