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

@property int skipClearingHighlightRequestCount;
// In some cases, we may want to keep the highlighted items a bit logner,
// so we use this variable to specify how many highlight claering requests
// need to be skipped.


+(HighlightedEntities*)sharedManager;

// Methods to access entities
- (NSMutableSet<SpatialEntity*>*)getHighlightedSet;
// This return all the entities with mapAnnotation enabled
- (void)addEntity:(SpatialEntity*)entity;
- (void)removeEntity:(SpatialEntity*)entity;

-(void)clearHighlightedSet;

@end
