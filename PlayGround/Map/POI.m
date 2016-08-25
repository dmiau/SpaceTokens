//
//  POI.m
//  SpaceBar
//
//  Created by Daniel on 2/1/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "POI.h"



@implementation POI

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


//----------------
// initialization
//----------------
- (id) init{
    self = [super init];
    if (self){
        _latLon = CLLocationCoordinate2DMake(0, 0);
        _coordSpan = MKCoordinateSpanMake(0.01, 0.01);
        _annotation = [[CustomPointAnnotation alloc] init];
        _headingInDegree = 0;
    }
    return self;
}

- (NSString*) description{
    return [NSString stringWithFormat:@"latlon: %@",
            [NSString stringWithFormat:@"%g, %g", self.latLon.latitude, self.latLon.longitude]];
}

// Custom set methods
- (void)setLatLon:(CLLocationCoordinate2D)latLon{
    _latLon = latLon;
    _annotation.coordinate = latLon;
}


- (void)setName:(NSString *)name{
    _name = name;
    _annotation.title = name;
}

// saving and loading the object
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeDouble:self.latLon.latitude forKey:@"latLon.latitdue"];
    [coder encodeDouble:self.latLon.longitude forKey:@"latLon.longitude"];
    [coder encodeObject:self.name forKey:@"name"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [self init];
    self.latLon = CLLocationCoordinate2DMake([coder decodeDoubleForKey:@"latLon.latitdue"], [coder decodeDoubleForKey:@"latLon.longitude"]);
    self.name = [coder decodeObjectOfClass:[NSString class] forKey:@"name"];
    
    return self;
}

// Deep copy
-(id) copyWithZone:(NSZone *) zone
{
    POI *object = [[POI alloc] init];
    object.latLon = self.latLon;
    object.name = self.name;
    return object;
}

@end
