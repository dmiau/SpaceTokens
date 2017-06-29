//
//  CustomPointAnnotation.h
//  NavTools
//
//  Created by dmiau on 8/16/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "AnnotationProtocol.h"

@class IconGenerator;

@interface CustomPointAnnotation : GMSMarker <AnnotationProtocol>
@property location_enum pointType;

@property bool isLabelOn;
@property BOOL isHighlighted;
@property UIColor *iconColor;
@property IconGenerator *iconGenerator;

@end
