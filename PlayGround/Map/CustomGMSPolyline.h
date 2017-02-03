//
//  CustomGMSPolyline.h
//  SpaceBar
//
//  Created by Daniel on 1/30/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "AnnotationProtocol.h"

@interface CustomGMSPolyline : GMSPolyline <AnnotationProtocol>
@property location_enum pointType;
@property bool isLabelOn;
@property BOOL isHighlighted;

-(id)initWithMKPolyline:(MKPolyline*) mkPolyline;

@end