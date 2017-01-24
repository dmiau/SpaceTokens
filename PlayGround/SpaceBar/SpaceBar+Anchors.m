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
        
        SpatialEntity *touchedKnownEntity = nil;
        // Check if the user touches any known entity
        for (SpatialEntity *anEntity in [[EntityDatabase sharedManager] getEntityArray])
        {
            if(MKMapRectContainsPoint(self.mapView.visibleMapRect, MKMapPointForCoordinate(anEntity.latLon)) &&
               anEntity.isEnabled && ![anEntity isKindOfClass:[ArrayEntity class]]
               && anEntity.annotation.isHighlighted
               && [anEntity getPointDistanceToTouch:aTouch] < 15
               )
            {
                touchedKnownEntity = anEntity;
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
            
            if (!touchedKnownEntity){
                // Create a POI for the anchor
                POI* aPOI = [[POI alloc] init];
                aPOI.latLon = coord;
                aPOI.name = [NSString stringWithFormat:@"Anchor%d", counter++];
                aPOI.coordSpan = self.mapView.region.span;
                aToken.spatialEntity = aPOI;
                [aToken configureAppearanceForType:ANCHOR_INVISIBLE];
            }else{
                aToken.spatialEntity = touchedKnownEntity;
                [aToken configureAppearanceForType:ANCHOR_VISIBLE];
                
                
                self.isSpaceTokenEnabled = YES;
            }
            
            if (self.isSpaceTokenEnabled){
                [self.anchorSet addObject:aToken];
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
            if ([aTouch force] > 0.5*[aTouch maximumPossibleForce] &&
                associatedToken.appearanceType != ANCHOR_VISIBLE)
            {
                [associatedToken configureAppearanceForType:ANCHOR_VISIBLE];
                associatedToken.spatialEntity.isMapAnnotationEnabled = YES;
                associatedToken.spatialEntity.annotation.isHighlighted = YES;
                
                // This enables the SpaceToken mode
                NSNotification *notification = [NSNotification notificationWithName:AddToDraggingSetNotification
                                                                             object:associatedToken userInfo:nil];
                [[ NSNotificationCenter defaultCenter] postNotification:notification];
                
                // Add the anchor to collection view
                [[EntityDatabase sharedManager] addEntity:associatedToken.spatialEntity];
                
                [[TokenCollectionView sharedManager] addItemFromBottom:associatedToken.spatialEntity];
                
            }
            
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
    [self.anchorSet removeObject:aToken];
    [self.anchorCandidateSet removeObject:aToken];
    aToken = nil;
}

- (void) removeAllAnchors{    
    for (SpaceToken *aToken in self.anchorSet){
        [self removeAnchor: aToken];
    }
    
    for (SpaceToken *aToken in self.anchorCandidateSet){
        [self removeAnchor: aToken];
    }
}

@end
