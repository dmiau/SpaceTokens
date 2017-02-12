//
//  EntityDatabase.h
//  SpaceBar
//
//  Created by dmiau on 11/14/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnnotationProtocol.h"

@class SpatialEntity;
@class Person;

@interface EntityDatabase : NSObject{
    NSMutableArray <SpatialEntity *> *cacheDefaultEntityArray;
    BOOL useDefaultEntityArray;
    NSMutableArray <SpatialEntity *> *i_entityArray;
}

@property NSString *name;
@property NSString *currentFileName;
@property Person *youRHere;


+(EntityDatabase*)sharedManager;

// temp POI array
- (void)useGameEntityArray:(NSMutableArray*)tempArray;
- (void)removeGameEntityArray;

// Methods to get entities
- (NSMutableArray<SpatialEntity*>*)getEntityArray;
- (NSMutableArray*)getEnabledEntities;


// This return all the entities with mapAnnotation enabled
- (void)setEntityArray:(NSMutableArray<SpatialEntity *> *)newEntityArray;
- (void)addEntity:(SpatialEntity*)entity;
- (void)removeEntity:(SpatialEntity*)entity;
- (void)removeEntitiesOfType:(location_enum)pointType;

// iCloud related methods
- (void)debugInit; // a temporary method
-(bool)saveDatatoFileWithName: (NSString*) fullPathFileName;
-(bool)loadFromFile:(NSString*) fullPathFileName;

@end
