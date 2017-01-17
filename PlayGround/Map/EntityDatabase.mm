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
    useDefaultEntityArray = YES;
    self.youRHere = [[Person alloc] init];
    self.isYouAreHereEnabled = YES;
    return self;
}

// methods to support a temporary POI array
- (void)useGameEntityArray:(NSMutableArray*)tempArray{
    useDefaultEntityArray = NO;
    self.entityArray = tempArray;
}

- (void)removeGameEntityArray{
    useDefaultEntityArray = YES;
    self.entityArray = cacheDefaultEntityArray;
}

//---------------
// Get a list of enabled entities
//---------------
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
    return i_entityArray;
}

- (void)addEntity:(SpatialEntity*)entity{
    
    // If the entity already exist, enable the entity
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@", entity];
    NSArray *filteredArray = [i_entityArray filteredArrayUsingPredicate:predicate];
    
    if ([filteredArray count] > 0){
        SpatialEntity *entity = [filteredArray firstObject];
        entity.isEnabled = YES;
    }else{
        [i_entityArray addObject:entity];
    }
}

- (void)removeEntity:(SpatialEntity*)entity{
    [i_entityArray removeObject:entity];
}

#pragma mark -- Save/Load --

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

//- (NSString*)description{
//    return @"";
//}

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

@end
