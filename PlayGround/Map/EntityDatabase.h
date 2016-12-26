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
}
@property NSString *name;
@property NSMutableArray <SpatialEntity *> *entityArray;
@property Person *youRHere;

+(EntityDatabase*)sharedManager;

// temp POI array
- (void)useGameEntityArray:(NSMutableArray*)tempArray;
- (void)removeGameEntityArray;

// iCloud related methods
- (void)debugInit; // a temporary method
-(bool)saveDatatoFileWithName: (NSString*) fullPathFileName;
-(bool)loadFromFile:(NSString*) fullPathFileName;

-(NSMutableArray*)getEnabledEntities;
@property BOOL isYouAreHereEnabled;

@end
