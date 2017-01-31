//
//  EntityDatabase.h
//  SpaceBar
//
//  Created by dmiau on 11/14/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SpatialEntity;
@class Person;

@interface EntityDatabase : NSObject{
    NSMutableArray <SpatialEntity *> *cacheDefaultEntityArray;
    BOOL useDefaultEntityArray;
    NSMutableArray <SpatialEntity *> *i_entityArray;
    NSMutableArray <SpatialEntity *> *temp_entityArray;
}

@property NSString *name;
@property Person *youRHere;

+(EntityDatabase*)sharedManager;

// temp POI array
- (void)useGameEntityArray:(NSMutableArray*)tempArray;
- (void)removeGameEntityArray;

// Methods to access entities
- (NSMutableArray<SpatialEntity*>*)getEntityArray;
- (void)setEntityArray:(NSMutableArray<SpatialEntity *> *)newEntityArray;
- (void)addEntity:(SpatialEntity*)entity;
- (void)removeEntity:(SpatialEntity*)entity;

// Methods to access temporary entities
- (void)addTempEntity:(SpatialEntity*)entity;
- (void)removeTempEntity:(SpatialEntity*)entity;
- (void)cleanTempEntities;

// iCloud related methods
- (void)debugInit; // a temporary method
-(bool)saveDatatoFileWithName: (NSString*) fullPathFileName;
-(bool)loadFromFile:(NSString*) fullPathFileName;

-(NSMutableArray*)getEnabledEntities;
@property BOOL isYouAreHereEnabled;

// Annotation management
-(void)resetAnnotations;


@end
