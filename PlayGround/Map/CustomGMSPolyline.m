//
//  CustomGMSPolyline.m
//  SpaceBar
//
//  Created by Daniel on 1/30/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "CustomGMSPolyline.h"
#import "CustomGMSPolygon.h"

@implementation CustomGMSPolyline{
    CustomGMSPolygon *_fillPolygon;
}

-(id)initWithMKPolyline:(MKPolyline*) mkPolyline{
    
    GMSMutablePath *path = [GMSMutablePath path];
    for (int i = 0; i < mkPolyline.pointCount; i++){
        [path addCoordinate:MKCoordinateForMapPoint(mkPolyline.points[i])];
    }
    
    self = [CustomGMSPolyline polylineWithPath:path];
    
    self.isHighlighted = NO;
    self.isLabelOn = NO;
    self.tappable = YES;
    self.isFilled = NO;
    self.pointType = path;
    return self;
}

-(id)initWithMKPolygon:(MKPolygon*) mkPolygon{
    
    GMSMutablePath *path = [GMSMutablePath path];
    for (int i = 0; i < mkPolygon.pointCount; i++){
        [path addCoordinate:MKCoordinateForMapPoint(mkPolygon.points[i])];
    }
    
    self = [CustomGMSPolyline polylineWithPath:path];
    
    self.isHighlighted = NO;
    self.isLabelOn = NO;
    self.tappable = YES;
    self.isFilled = YES;
    self.pointType = AREA;
    _fillPolygon = [CustomGMSPolygon polygonWithPath:path];
    _fillPolygon.tappable = NO;
    
    return self;
}

-(id) init{
    self = [super init];
    self.tappable = YES;
    return self;
}

-(void)setIsFilled:(BOOL)isFilled{
    _isFilled = isFilled;
    if(!isFilled){
        _fillPolygon.map = nil;
    }else{
        _fillPolygon.map = self.map;
    }
}

-(void)setIsHighlighted:(BOOL)isHighlighted{
    _isHighlighted = isHighlighted;
    
    if (isHighlighted){
        self.strokeWidth = 2;
        self.strokeColor = [UIColor blueColor];
    }else{
        self.strokeWidth = 1;
        self.strokeColor = [UIColor grayColor];
    }
    
    if (self.isFilled){
        _fillPolygon.map = self.map;
        _fillPolygon.isHighlighted = isHighlighted;
    }
}

@end
