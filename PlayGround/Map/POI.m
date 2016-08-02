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
    }
    return self;
}

- (NSString*) description{
    return [NSString stringWithFormat:@"latlon: %@ \n mapViewXY: %@",
            [NSString stringWithFormat:@"%g, %g", self.latLon.latitude, self.latLon.longitude]
            , NSStringFromCGPoint(self.mapViewXY)];
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


@end
