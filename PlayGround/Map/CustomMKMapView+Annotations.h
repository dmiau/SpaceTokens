//
//  CustomMKMapView+Annotations.h
//  SpaceBar
//
//  Created by dmiau on 9/28/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "CustomMKMapView.h"

@class CustomPointAnnotation;

@interface CustomMKMapView (Annotations)

// Handle annotation interactions (redirected from delegates)
- (bool)didTapMarker:(CustomPointAnnotation *)marker;
- (void)didTapAtCoordinate:	(CLLocationCoordinate2D) coordinate;
- (void)didTapOverlay:(GMSOverlay *)overlay;
- (void)didTapPOIWithPlaceID:(NSString *)placeID
           name:(NSString *)name
                    location:(CLLocationCoordinate2D)location;
- (void)didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate;

- (void)highlightEntity:(SpatialEntity*)entity andResetOthers:(BOOL)resetFlag;
@end
