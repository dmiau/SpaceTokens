//
//  Area.m
//  SpaceBar
//
//  Created by Daniel on 12/30/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "Area.h"
#import "CustomMKMapView.h"
#include "NSValue+MKMapPoint.h"

@implementation Area
- (id)initWithMKMapPointArray: (NSArray*) mapPointArray{
    
    self = [super initWithMKMapPointArray:mapPointArray];
    self.annotation.pointType = AREA;
    self.name = @"UnNamedArea";
    return self;
}

//-----------------
// Save/Load
//-----------------
// saving and loading the object
- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    self.annotation.pointType = AREA;
    return self;
}
@end
