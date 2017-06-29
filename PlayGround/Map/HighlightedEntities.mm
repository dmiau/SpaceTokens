//
//  HighlightedEntities.m
//  NavTools
//
//  Created by dmiau on 2/8/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "HighlightedEntities.h"
#import "SpatialEntity.h"
#import "CustomMKMapView.h"
#import "InformationSheetManager.h"

#import "Route.h"
#import "POI.h"

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
    _skipClearingHighlightRequestCount = 0;
    return self;
}

// MARK: Access methods
- (NSMutableSet<SpatialEntity*>*)getHighlightedSet{
    return _highlightedSet;
}

// This return all the entities with mapAnnotation enabled
- (void)addEntity:(SpatialEntity*)entity{
    
    [_highlightedSet addObject:entity];
    entity.isMapAnnotationEnabled = YES;
    entity.annotation.isHighlighted = YES;
    
    // Show a collection information sheet if multiple items are highlighted
    if([entity isMemberOfClass:[Route class]]){
        [[[CustomMKMapView sharedManager] informationSheetManager]
         addSheetForEntity:entity];
    }else if( [_highlightedSet count]==1){
        [[[CustomMKMapView sharedManager] informationSheetManager]
         addSheetForEntity:entity];
    }else{
        //-------------------
        // More than one item is highlighted
        //-------------------
        Route *tempRoute = [[Route alloc] init];
        tempRoute.name = [NSString stringWithFormat:@"%lu items", (unsigned long)[_highlightedSet count]];
        tempRoute.appearanceMode = SETMODE;
        for (SpatialEntity* anEntity in _highlightedSet){
            if ([anEntity isMemberOfClass:[POI class]]){
                [tempRoute addObject:anEntity];
            }
        }

        [[[CustomMKMapView sharedManager] informationSheetManager]
         addSheetForEntity:tempRoute];
    }
}

- (void)removeEntity:(SpatialEntity*)entity{
    [_highlightedSet removeObject:entity];
    entity.annotation.isHighlighted = NO;
}


// MARK: Clear the annotation
//---------------------------

-(void)clearHighlightedSet{
    
    if (_skipClearingHighlightRequestCount > 0){
        _skipClearingHighlightRequestCount -= _skipClearingHighlightRequestCount;
        return;
    }
    
    // Get all the annotations
    for (SpatialEntity *anEntity in [_highlightedSet copy]){
        if (!anEntity.isAnchor)
            [self removeEntity:anEntity];
    }
}


// MARK: Debug
//---------------------------
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
