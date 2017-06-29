  //
//  ArrayEntity.h
//  NavTools
//
//  Created by Daniel on 1/2/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "SpatialEntity.h"

@interface ArrayEntity : SpatialEntity{
    NSMutableArray <SpatialEntity *> *contentArray;
}

@property (nonatomic, copy) void (^contentUpdatedBlock)();

-(void)updateBoundingMapRect;

// Methods to modify contentArray
-(void)insertObject:(id)object atIndex:(NSUInteger)index;
-(void)removeObjectAtIndex:(NSUInteger)index;
-(void)addObject:(id)object;
-(void)addObjectsFromArray:(NSArray*)objects;
-(void)removeObject:(id)object;

-(NSArray <SpatialEntity*> *)getContent;
-(void)setContent:(NSArray <SpatialEntity*> *)inputArray;

// Get the bounding box of the entities
-(MKMapRect)getBoundingMapRect;
@end
