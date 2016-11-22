//
//  CustomPointAnnotation.h
//  SpaceBar
//
//  Created by dmiau on 8/16/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <MapKit/MapKit.h>

typedef enum {
    landmark,
    dropped,
    search_result,
    YouRHere,
    people,
    answer
} location_enum;

@interface CustomPointAnnotation : MKPointAnnotation
@property location_enum pointType;

@property bool isLableOn;
@property UIImage *annotationImage;
@property UILabel *aLabel;
@end
