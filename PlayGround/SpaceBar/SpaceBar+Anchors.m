//
//  SpaceBar+Anchors.m
//  SpaceBar
//
//  Created by dmiau on 9/13/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SpaceBar+Anchors.h"
#import "POI.h"
#import "EntityDatabase.h"
#import "Constants.h"
#import "TokenCollectionView.h"
#import "ArrayTool.h"
#import "ArrayEntity.h"
#import "HighlightedEntities.h"

// This object records the information associated with an anchor touch.
// The information will be used to classify a tap event later on
@interface AnchorTouchInfo : NSObject
@property UITouch *touch;
@property CGPoint originalPoint;
@property NSDate *startTime;
@property SpatialEntity *touchedEntity;
@end


@implementation AnchorTouchInfo
// empty implementation
@end


@implementation SpaceBar (Anchors)

// Add anchors to the candidateArray first, move anchors to anchorSet when
// SpaceToken mode is enabled.

- (void) addAnchorForTouches:(NSSet<UITouch *> *)touches{
    
    static int counter = 0;
    // Note: there could be more than one touch point
    for (UITouch *aTouch in touches){
        
        CGPoint mapXY = [aTouch locationInView:self.mapView];
        CLLocationCoordinate2D coord = [self.mapView convertPoint:mapXY
                                             toCoordinateFromView:self.mapView];
        
        // Collect all the known entities
        NSMutableSet *entitySet = [NSMutableSet set];
        [entitySet addObjectsFromArray:[[EntityDatabase sharedManager] getEntityArray]];
        [entitySet unionSet: [[HighlightedEntities sharedManager]  getHighlightedSet]];
        
        SpatialEntity *touchedHighlightedEntity = nil;
        // Check if the user touches any known (highlighted) entity
        for (SpatialEntity *anEntity in entitySet)
        {
            if(MKMapRectContainsPoint(self.mapView.visibleMapRect, MKMapPointForCoordinate(anEntity.latLon))
               && ![anEntity isKindOfClass:[ArrayEntity class]]
               && anEntity.annotation.isHighlighted
               && [anEntity isEntityTouched:aTouch]
               )
            {
                touchedHighlightedEntity = anEntity;
                break;
            }
        }
        
        // Check if the user touches any known (but unhighlighted) entity
        SpatialEntity *touchedKnownUnHighlightedEntity = nil;
        // Check if the user touches any known entity
        for (SpatialEntity *anEntity in entitySet)
        {
            if(MKMapRectContainsPoint(self.mapView.visibleMapRect, MKMapPointForCoordinate(anEntity.latLon))
               && ![anEntity isKindOfClass:[ArrayEntity class]]
               && !anEntity.annotation.isHighlighted
               && [anEntity isEntityTouched:aTouch]
               )
            {
                touchedKnownUnHighlightedEntity = anEntity;
                break;
            }
        }
        
        
        // Check if the touch is already associated with any anchor
        // Do nothing if there is an anchor associated with the given touch
        if (![self findRelatedToAnchor:aTouch]){
            
            //------------------
            // Create a SpaceToken if one does not exist yet
            //------------------
            
            // create a new POI for anchor if an anchor does not exist
            SpaceToken *aToken = [[SpaceToken alloc] init];
            
            // Position the SpaceToken correctly
            aToken.center = mapXY;
            aToken.mapViewXY = mapXY;
            aToken.touch = aTouch;
            // Add the anchor to the map
            [self.mapView addSubview:aToken];
            
            if (touchedHighlightedEntity){
                // The user touches a highlighted entity.
                // Anchor should be on in this case
                aToken.spatialEntity = touchedHighlightedEntity;
                [aToken configureAppearanceForType:ANCHOR_VISIBLE];
                self.isSpaceTokenEnabled = YES;
            }else if (touchedKnownUnHighlightedEntity){
                // The user touches a known (but unhighlighed) entity.
                // Store the information into the structure.
                // This entity should be highlighted if it turns out is a
                // tap event.
                
                // Add the touch info to anchorTouchInfoDictionary
                AnchorTouchInfo *touchInfor = [[AnchorTouchInfo alloc] init];
                touchInfor.touch = aTouch;
                touchInfor.originalPoint = [aTouch locationInView:self.mapView];
                touchInfor.touchedEntity = touchedKnownUnHighlightedEntity;
                touchInfor.startTime = [NSDate date];
                [self.anchorTouchInfoArray addObject:touchInfor];

                aToken.spatialEntity = touchedKnownUnHighlightedEntity;
                [aToken configureAppearanceForType:ANCHOR_INVISIBLE];                
            }else{
                // User touches a random area.
                
                if ([self.anchorSet count] > 0){
                    // All the highlighted entity should be cleared.
                    // (only when there is an active anchor)
                    [[HighlightedEntities sharedManager] clearHighlightedSet];
                }
                
                // Create a POI for the anchor
                POI* aPOI = [[POI alloc] init];
                aPOI.latLon = coord;
                aPOI.name = [NSString stringWithFormat:@"Anchor%d", counter++];
                aPOI.coordSpan = self.mapView.region.span;
                aToken.spatialEntity = aPOI;
                [aToken configureAppearanceForType:ANCHOR_INVISIBLE];
            }
            
            if (self.isSpaceTokenEnabled){
                [self.anchorSet addObject:aToken];
                aToken.spatialEntity.isAnchor = YES;
                [self.draggingSet addObject:aToken];
            }else{
                [self.anchorCandidateSet addObject:aToken];
            }
        }
    }
}

- (SpaceToken*) findRelatedToAnchor:(UITouch*) touch{
    SpaceToken *foundToken = nil;
    for (SpaceToken *aToken in self.anchorSet){
        if (aToken.touch == touch)
            return aToken;
    }
    
    for (SpaceToken *aToken in self.anchorCandidateSet){
        if (aToken.touch == touch)
            return aToken;
    }
    return foundToken;
}

// Returns the AnchorTouchInfo object related to touch
-(AnchorTouchInfo*)findAnchorTouchInfo:(UITouch*) touch{
    AnchorTouchInfo* output = nil;
    for (AnchorTouchInfo* touchInfo in self.anchorTouchInfoArray){
        if (touchInfo.touch == touch){
            output = touchInfo;
            break;
        }
    }
    return output;
}

- (void) updateAnchorForTouches:(NSSet<UITouch *> *)touches
{
    // Only update the registered anchors
    for (UITouch *aTouch in touches){
        SpaceToken *associatedToken = [self findRelatedToAnchor:aTouch];
        if (associatedToken){
            CGPoint mapXY = [aTouch locationInView:self.mapView];
            
            
            // Check if the * highlighted * token is being pushed into the insertion zone
            if (associatedToken.spatialEntity.annotation.isHighlighted
                && !self.isStudyModeEnabled
                && self.isAnchorAllowed)
            {
            
                // Check if the token is to be inserted into any of the structure
                NSMutableArray <dragActionHandlingBlock> *handlingBlockArray =
                [[TokenCollection sharedManager] handlingBlockArray];
                
                //----------------------
                // Insert to a structure?
                //----------------------
                for (dragActionHandlingBlock block in handlingBlockArray){
                    if (block(aTouch, associatedToken)){
                        NSLog(@"Insert from anchor");
                        [self removeAnchor: associatedToken];
                        return;
                    }
                }
                
            }
            
            // The token is not highlighed and is NOT being pushed into the insertion zone
                
            // Position the SpaceToken correctly
            associatedToken.center = mapXY;
            associatedToken.mapViewXY = mapXY;
            
            // Depending on the pressure, we may need to turn a ANCHOR_INVISIBLE
            // to a ANCHOR_VISIBLE and enable the SpaceToken mode
//            if ([aTouch force] > 0.5*[aTouch maximumPossibleForce] &&
//                associatedToken.appearanceType != ANCHOR_VISIBLE)
//            {
//                [associatedToken configureAppearanceForType:ANCHOR_VISIBLE];
//                
//                // This enables the SpaceToken mode
//                NSNotification *notification = [NSNotification notificationWithName:AddToDraggingSetNotification
//                                                                             object:associatedToken userInfo:nil];
//                [[ NSNotificationCenter defaultCenter] postNotification:notification];
//                
//                // Add the anchor to collection view
//                [[EntityDatabase sharedManager] addEntity:associatedToken.spatialEntity];
//                
//                [[TokenCollectionView sharedManager] addItemFromBottom:associatedToken.spatialEntity];
//                
//            }
            
        }
    }
}

- (void) removeAnchorForTouches: (NSSet<UITouch *> *)touches{
    for (UITouch *aTouch in touches){
        SpaceToken *aToken = [self findRelatedToAnchor:aTouch];
        if (aToken){
            [self removeAnchor:aToken];
        }
    }
}

- (void) removeAnchor: (SpaceToken*) aToken{
    // remove the anchor from the dragging set
    [self.draggingSet removeObject:aToken];
    [aToken removeFromSuperview];
    aToken.spatialEntity.isAnchor = NO;
    [self.anchorSet removeObject:aToken];
    [self.anchorCandidateSet removeObject:aToken];
    
    // Check if the removing anchor resulted in a tap
    AnchorTouchInfo *touchInfo = [self findAnchorTouchInfo:aToken.touch];
    if (touchInfo){
        NSLog(@"touchInfo found!");
        
        // Cacluate the distance
        CGPoint currentPoint = [aToken.touch locationInView:self.mapView];
        double dist = pow((touchInfo.originalPoint.x - currentPoint.x), 2) +
        pow((touchInfo.originalPoint.y - currentPoint.y), 2);
        
        double elapsedTime = [touchInfo.startTime timeIntervalSinceNow];
        
        if (elapsedTime < 0.3 && dist < 225){
            [[HighlightedEntities sharedManager] clearHighlightedSet];
            // Tap the point
            [[HighlightedEntities sharedManager] addEntity:touchInfo.touchedEntity];
        }
    }
    
    
    aToken = nil;
}

- (void) removeAllAnchors{    
    for (SpaceToken *aToken in self.anchorSet){
        [self removeAnchor: aToken];
    }
    
    for (SpaceToken *aToken in self.anchorCandidateSet){
        [self removeAnchor: aToken];
    }
    
    [self.anchorTouchInfoArray removeAllObjects];
}

@end
