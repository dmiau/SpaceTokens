//
//  CustomMKPolyline.h
//  SpaceBar
//
//  Created by dmiau on 1/15/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface CustomMKPolyline : MKPolyline

@property bool isLableOn;
@property BOOL isHighlighted;

- (MKOverlayRenderer *)generateOverlayRenderer;
@end
