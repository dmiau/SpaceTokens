//
//  CustomPointAnnotation.h
//  SpaceBar
//
//  Created by dmiau on 8/16/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "AnnotationProtocol.h"

@interface CustomPointAnnotation : GMSMarker <AnnotationProtocol>
@property location_enum pointType;

@property bool isLabelOn;
@property BOOL isHighlighted;

@end
