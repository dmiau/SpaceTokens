//
//  HighlightedEntities.m
//  SpaceBar
//
//  Created by dmiau on 2/8/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "HighlightedEntities.h"
#import "SpatialEntity.h"
#import "CustomMKMapView.h"
#import "InformationSheetManager.h"

@implementation HighlightedEntities

// MARK: Initialization
+(HighlightedEntities*)sharedManager{
    static HighlightedEntities *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HighlightedEntities alloc] init];
    });
    return sharedInstance;
}

-(id)init{
    self = [super init];
    _highlightedSet = [NSMutableSet set];
    return self;
}

// MARK: Access methods
- (NSMutableSet<SpatialEntity*>*)getHighlightedSet{
    return _highlightedSet;
}

// This return all the entities with mapAnnotation enabled
- (void)addEntity:(SpatialEntity*)entity{
    
//    // Need to reset annotation based on type
//    [self resetAnnotationBasedOnCurrentEntity: entity];
    
    [_highlightedSet addObject:entity];
    self.lastHighlightedEntity = entity;
    entity.isMapAnnotationEnabled = YES;
    entity.annotation.isHighlighted = YES;
    [[[CustomMKMapView sharedManager] informationSheetManager]
     addSheetForEntity:entity];
}

- (void)removeEntity:(SpatialEntity*)entity{
    [_highlightedSet removeObject:entity];
    entity.annotation.isHighlighted = NO;
}


// MARK: Clear the annotation
// based on the current entity, we need to reset the annotation differently
-(void)resetAnnotationBasedOnCurrentEntity:(SpatialEntity*) entity{
    // Currently, we clear all annotation except the search
    [self clearAllHIghlightedEntitiesButType:SEARCH_RESULT];
}

-(void)clearHighlightedSet{
    self.lastHighlightedEntity = nil;
    
    // Get all the annotations
    for (SpatialEntity *anEntity in [_highlightedSet copy]){
        [self removeEntity:anEntity];
    }
}

-(void)clearHIghlightedEntitiesOfType:(location_enum)pointType{
    // Get all the annotations
    for (SpatialEntity *anEntity in [_highlightedSet copy]){
        if (anEntity.annotation.pointType == pointType){
            [self removeEntity:anEntity];
        }
    }
}

-(void)clearAllHIghlightedEntitiesButType:(location_enum)pointType{
    // Get all the annotations
    for (SpatialEntity *anEntity in [_highlightedSet copy]){
        if (anEntity.annotation.pointType != pointType){
            [self removeEntity:anEntity];
        }
    }
}


// MARK: Debug
-(NSString*)description{
    NSMutableArray *lines = [NSMutableArray array];
    [lines addObject:[NSString stringWithFormat:@"Highlighted entity #: %lu",
                      (unsigned long)[_highlightedSet count]]];
    for (SpatialEntity *entity in _highlightedSet){
        [lines addObject:entity.name];
    }    
    return [lines componentsJoinedByString:@"\n"];
}

@end
