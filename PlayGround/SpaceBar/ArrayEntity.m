//
//  ArrayEntity.m
//  SpaceBar
//
//  Created by Daniel on 1/2/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "ArrayEntity.h"

@implementation ArrayEntity
// MARK: Initialization
-(id)init{
    self = [super init];
    self.name = @"NoNamed";
    self.contentArray = [NSMutableArray array];
    return self;
}

// MARK: Save/load
// saving and loading the object
- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject: self.contentArray forKey:@"contentArray"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    // Decode source and destination
    self.contentArray = [coder decodeObjectOfClass:[NSMutableArray class] forKey:@"contentArray"];
    return self;
}

-(id) copyWithZone:(NSZone *) zone
{
    // This is very important, since a child class might call this method too.
    ArrayEntity *object = [[[self class] alloc] init];
    object = [super copy];
    object.contentArray = [self.contentArray mutableCopy];
    return object;
}

-(void)updateBoundingMapRect{
    MKCoordinateRegion region = MKCoordinateRegionForMapRect([self getBoundingMapRect]);
    
    self.latLon = region.center;
    self.coordSpan = region.span;
}

-(MKMapRect)getBoundingMapRect{
    double minMapX = 0.0, maxMapX = 0.0, minMapY = 0.0, maxMapY = 0.0;
    
    int i = 0;
    for (SpatialEntity *anEntity in self.contentArray){
        CLLocationCoordinate2D minLatLon = CLLocationCoordinate2DMake(
        anEntity.latLon.latitude - anEntity.coordSpan.latitudeDelta,
        anEntity.latLon.longitude - anEntity.coordSpan.longitudeDelta                                                          );
        CLLocationCoordinate2D maxLatLon = CLLocationCoordinate2DMake(
        anEntity.latLon.latitude + anEntity.coordSpan.latitudeDelta,
        anEntity.latLon.longitude + anEntity.coordSpan.longitudeDelta                                                          );
        
        MKMapPoint minMapPoint = MKMapPointForCoordinate(minLatLon);
        MKMapPoint maxMapPoint = MKMapPointForCoordinate(maxLatLon);
        if (i == 0){
            minMapX = minMapPoint.x; maxMapX = maxMapPoint.x;
            minMapY = minMapPoint.y; maxMapY = maxMapPoint.y;
        }else{
            minMapX = fmin(minMapX, minMapPoint.x);
            minMapY = fmin(minMapY, minMapPoint.y);
            maxMapX = fmax(maxMapX, maxMapPoint.x);
            maxMapY = fmax(maxMapY, maxMapPoint.y);
        }
        i++;
    }
    
    MKMapRect output = MKMapRectMake(minMapX, minMapY,
                                     maxMapX - minMapX, maxMapY - minMapY);
    return output;
}

@end
