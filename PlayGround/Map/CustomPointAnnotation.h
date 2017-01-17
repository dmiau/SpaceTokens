//
//  CustomPointAnnotation.h
//  SpaceBar
//
//  Created by dmiau on 8/16/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "AnnotationProtocol.h"

@interface CustomPointAnnotation : MKPointAnnotation <AnnotationProtocol>
@property location_enum pointType;

@property bool isLableOn;
@property BOOL isHighlighted;

-(MKAnnotationView *)generateAnnotationView;
@end
