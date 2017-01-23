//
//  ArrayEntity.m
//  SpaceBar
//
//  Created by Daniel on 1/2/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "ArrayEntity.h"
#import "CustomMKMapView.h"

@implementation ArrayEntity
// MARK: Initialization
-(id)init{
    self = [super init];
    self.name = @"UnNamed";
    contentArray = [NSMutableArray array];
    return self;
}

// MARK: Save/load
// saving and loading the object
- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject: contentArray forKey:@"contentArray"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    // Decode source and destination
    contentArray = [coder decodeObjectOfClass:[NSMutableArray class] forKey:@"contentArray"];
    self.contentUpdatedBlock = nil;
    return self;
}

-(id) copyWithZone:(NSZone *) zone
{
    // This is very important, since a child class might call this method too.
    ArrayEntity *object = [[[self class] alloc] init];
    object = [super copy];
    [object setContent:contentArray];
    return object;
}

-(void)updateBoundingMapRect{
    MKCoordinateRegion region = MKCoordinateRegionForMapRect([self getBoundingMapRect]);
    
    self.latLon = region.center;
    self.coordSpan = region.span;
}

-(MKMapRect)getBoundingMapRect{
    
    if ([contentArray count]==0){
        
        return [CustomMKMapView MKMapRectForCoordinateRegion:
                [[CustomMKMapView sharedManager] region]];
    }
    
    double minMapX = 0.0, maxMapX = 0.0, minMapY = 0.0, maxMapY = 0.0;
    
    int i = 0;
    for (SpatialEntity *anEntity in contentArray){
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

// MARK: Methods to modify contentArray
-(void)insertObject:(id)object atIndex:(NSUInteger)index{
    [contentArray insertObject:object atIndex:index];
    [self updateBoundingMapRect];
    if (self.contentUpdatedBlock){
        self.contentUpdatedBlock();
    }
}

-(void)addObject:(id)object{
    [contentArray addObject:object];
    [self updateBoundingMapRect];
    if (self.contentUpdatedBlock){
        self.contentUpdatedBlock();
    }
}

-(void)addObjectsFromArray:(NSArray*)objects{
    [contentArray addObjectsFromArray:objects];
    [self updateBoundingMapRect];
    if (self.contentUpdatedBlock){
        self.contentUpdatedBlock();
    }
}

-(void)removeObject:(id)object{
    [contentArray removeObject:object];
    [self updateBoundingMapRect];
    if (self.contentUpdatedBlock){
        self.contentUpdatedBlock();
    }
}

-(void)removeObjectAtIndex:(NSUInteger)index{
    [contentArray removeObjectAtIndex:index];
    [self updateBoundingMapRect];
    if (self.contentUpdatedBlock){
        self.contentUpdatedBlock();
    }
}

-(NSArray <SpatialEntity*> *)getContent{
    return [NSArray arrayWithArray:contentArray];
}

-(void)setContent:(NSArray <SpatialEntity*> *)inputArray{
    contentArray = [inputArray mutableCopy];
    [self updateBoundingMapRect];
    
    if (self.contentUpdatedBlock){
        self.contentUpdatedBlock();
    }
}

@end
