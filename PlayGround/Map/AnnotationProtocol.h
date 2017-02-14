//
//  AnnotationProtocol.h
//  SpaceBar
//
//  Created by dmiau on 1/16/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import <MapKit/MapKit.h>

typedef enum {
    LANDMARK,
    STAR,
    TOKENSTAR,
    path,
    AREA,
    DROPPED,
    SEARCH_RESULT,
    YouRHere,
    PEOPLE,
    DEFAULT_MARKER
} location_enum;

@protocol AnnotationProtocol <NSObject>
@property location_enum pointType;

@property bool isLabelOn;
@property BOOL isHighlighted;
@end
