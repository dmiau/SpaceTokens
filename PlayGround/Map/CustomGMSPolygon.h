//
//  CustomGMSPolygon.h
//  SpaceBar
//
//  Created by Daniel on 1/30/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "AnnotationProtocol.h"

@interface CustomGMSPolygon : GMSPolygon
@property location_enum pointType;
@property bool isLabelOn;
@property BOOL isHighlighted;

-(id)initWithMKPolygon:(MKPolygon*) mkPolygon;
@end
