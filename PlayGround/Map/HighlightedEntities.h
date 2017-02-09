//
//  HighlightedEntities.h
//  SpaceBar
//
//  Created by dmiau on 2/8/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnnotationProtocol.h"

@class SpatialEntity;

@interface HighlightedEntities : NSObject{
    NSMutableSet <SpatialEntity *> *_highlightedSet;
}

+(HighlightedEntities*)sharedManager;

@property SpatialEntity *lastHighlightedEntity;

// Methods to access entities
- (NSMutableSet<SpatialEntity*>*)getHighlightedSet;
// This return all the entities with mapAnnotation enabled
- (void)addEntity:(SpatialEntity*)entity;
- (void)removeEntity:(SpatialEntity*)entity;

-(void)clearHighlightedSet;
-(void)clearHIghlightedEntitiesOfType:(location_enum)pointType;
@end
