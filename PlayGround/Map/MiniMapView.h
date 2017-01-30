//
//  MiniMapView.h
//  SpaceBar
//
//  Created by Daniel on 8/11/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "CustomMKMapView.h"

@interface MiniMapView : CustomMKMapView <MKMapViewDelegate, CustomMKMapViewDelegate>

@property MKPolyline *boxPolyline;
@property BOOL syncRotation;

- (void) updateBox: (CustomMKMapView*) aMapView;
- (void) removeRouteOverlays;
@end
