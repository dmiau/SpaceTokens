//
//  CustomGMSPolyline.m
//  SpaceBar
//
//  Created by Daniel on 1/30/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "CustomGMSPolyline.h"

@implementation CustomGMSPolyline

-(id)initWithMKPolyline:(MKPolyline*) mkPolyline{
    
    GMSMutablePath *path = [GMSMutablePath path];
    for (int i = 0; i < mkPolyline.pointCount; i++){
        [path addCoordinate:MKCoordinateForMapPoint(mkPolyline.points[i])];
    }
    
    self = [CustomGMSPolyline polylineWithPath:path];
    
    self.isHighlighted = NO;
    self.isLabelOn = NO;
    self.tappable = YES;
    return self;
}

//--------------
// Setters
//--------------
-(void)setIsHighlighted:(BOOL)isHighlighted{
    _isHighlighted = isHighlighted;
    
    if (isHighlighted){
        self.strokeWidth = 2;
        self.strokeColor = [UIColor blueColor];
    }else{
        self.strokeWidth = 1;
        self.strokeColor = [UIColor grayColor];
    }
}

@end
