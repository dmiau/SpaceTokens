//
//  EntityDatabase.m
//  SpaceBar
//
//  Created by dmiau on 11/14/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "EntityDatabase.h"
#import "SpatialEntity.h"
#import "MyFileManager.h"
#import "Person.h"
#import "RouteDatabase.h"

@implementation EntityDatabase

+(EntityDatabase*)sharedManager{
    static EntityDatabase *sharedEntityDatabase = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEntityDatabase = [[EntityDatabase alloc] init];
    });
    return sharedEntityDatabase;
}

- (id) init{
    i_entityArray = [[NSMutableArray alloc] init];
    cacheDefaultEntityArray = [[NSMutableArray alloc] init];
    temp_entityArray = [[NSMutableArray alloc] init];
    useDefaultEntityArray = YES;
    self.youRHere = [[Person alloc] init];
    self.isYouAreHereEnabled = YES;
    return self;
}


// MARK: methods to support Game entity array
//----------------------------------------------------------
- (void)useGameEntityArray:(NSMutableArray*)tempArray{
    useDefaultEntityArray = NO;
    self.entityArray = tempArray;
}

- (void)removeGameEntityArray{
    useDefaultEntityArray = YES;
    self.entityArray = cacheDefaultEntityArray;
}

// MARK: Access the entity array
-(NSMutableArray*)getEnabledEntities{
    NSMutableArray* outArray = [[NSMutableArray alloc] init];
    
    for (SpatialEntity *anEntity in i_entityArray){
        if (anEntity.isEnabled){
            [outArray addObject:anEntity];
        }
    }
    
    // Decide if youAreHere should be added
    if (self.isYouAreHereEnabled && useDefaultEntityArray){
        [outArray addObject:self.youRHere];
    }
        
    return outArray;
}

- (void)setEntityArray:(NSMutableArray<SpatialEntity *> *)newEntityArray{
    if (useDefaultEntityArray){
        cacheDefaultEntityArray = [newEntityArray mutableCopy];
    }
    i_entityArray = [newEntityArray mutableCopy];
}

- (NSMutableArray*)getEntityArray{
    
    NSMutableArray *outArray = [NSMutableArray arrayWithArray:i_entityArray];
    [outArray addObjectsFromArray:temp_entityArray];
    
    if (self.lastHighlightedEntity){
        [outArray addObject:self.lastHighlightedEntity];
    }
    
    return outArray;
}

- (void)addEntity:(SpatialEntity*)entity{
    
    // If the entity already exist, enable the entity
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@", entity];
    NSArray *filteredArray = [i_entityArray filteredArrayUsingPredicate:predicate];
    
    if ([filteredArray count] > 0){
        SpatialEntity *entity = [filteredArray firstObject];
    }else{
        [i_entityArray addObject:entity];
    }
}

- (void)removeEntity:(SpatialEntity*)entity{
    [i_entityArray removeObject:entity];
}

// MARK: Access the temporary entity array
//----------------------------------------------------------
- (void)addTempEntity:(SpatialEntity*)entity{
    [temp_entityArray addObject: entity];
}

- (void)removeTempEntity:(SpatialEntity*)entity{
    [temp_entityArray removeObject:entity];
}

- (void)cleanTempEntities{
    
    for (SpatialEntity *anEntity in temp_entityArray){
        anEntity.isMapAnnotationEnabled = NO;
    }
    [temp_entityArray removeAllObjects];
}


// MARK: Annotation management
//----------------------------------------------------------
-(void)resetAnnotations{
    
    [self cleanTempEntities];
    
    // Get all the annotations
    for (SpatialEntity *anEntity in [self getEntityArray]){
//        anEntity.isMapAnnotationEnabled = YES;
        anEntity.annotation.isHighlighted = NO;
        anEntity.annotation.isLabelOn = NO;
    }
}

-(SpatialEntity*)entityForAnnotation:(id)anntation{
    SpatialEntity *result = nil;
    
    for (SpatialEntity *entity in [self getEntityArray]){
        if (entity.annotation == anntation){
            result = entity;
            break;
        }
    }
    
    return result;
}


// MARK: -- Save/Load --
//----------------------------------------------------------

// saving and loading the object
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:i_entityArray forKey:@"entityArray"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [self init];
    self.name = [coder decodeObjectForKey:@"name"];
    self.entityArray = [[coder decodeObjectForKey:@"entityArray"] mutableCopy];
    return self;
}

#pragma mark -- iCloud --

//------------------
// Loading a debug database
//------------------
- (void)debugInit{
    MyFileManager *myFileManager = [MyFileManager sharedManager];
    
    NSString *dirPath = [myFileManager currentFullDirectoryPath];
    NSString *fileFullPath = [dirPath stringByAppendingPathComponent:@"myTest.entitydb"];
    [self loadFromFile:fileFullPath];
}

// Good reference: http://www.idev101.com/code/Objective-C/Saving_Data/NSKeyedArchiver.html

- (bool)saveDatatoFileWithName: (NSString*) fullPathFileName{
    // Save the entire database to a file
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject: self];
    
    if ([data writeToFile:fullPathFileName atomically:YES]){
        NSLog(@"%@ saved successfully!", fullPathFileName);
        return YES;
    }else{
        NSLog(@"Failed to save %@", fullPathFileName);
        return NO;
    }
}

- (bool)loadFromFile:(NSString*) fullPathFileName{
    
    // Read content from a file
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:fullPathFileName]){
        
        NSData *data = [NSData dataWithContentsOfFile:fullPathFileName];
        EntityDatabase *entityDB = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        self.name = entityDB.name;
        self.entityArray = [entityDB getEntityArray];
        return YES;
    }else{
        NSLog(@"%@ does not exist.", fullPathFileName);
        return NO;
    }
}

- (NSString*)description{
    NSMutableArray *lines = [NSMutableArray array];
    [lines addObject:
     [NSString stringWithFormat:@"entityArray #: %lu", (unsigned long)[i_entityArray count]]];
    
    [lines addObject:
     [NSString stringWithFormat:@"temp_entityArray #: %lu", (unsigned long)[temp_entityArray count]]];
    
    [lines addObject:
     [NSString stringWithFormat:@"lastHighlightedEntity: %@", self.lastHighlightedEntity]];
    
    return [lines componentsJoinedByString:@"\n"];
}

@end
