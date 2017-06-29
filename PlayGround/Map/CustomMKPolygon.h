//
//  CustomMKPolygon.h
//  NavTools
//
//  Created by dmiau on 1/15/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "AnnotationProtocol.h"

@interface CustomMKPolygon : MKPolygon <AnnotationProtocol>
@property location_enum pointType;
@property BOOL isLabelOn;
@property BOOL isHighlighted;

- (MKOverlayRenderer *)generateOverlayRenderer;
@end
