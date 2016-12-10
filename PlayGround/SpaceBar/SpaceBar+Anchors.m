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
        
        // Check if the touch is already associated with any anchor
        if (![self findRelatedToAnchor:aTouch]){
            
            //------------------
            // Create a SpaceToken if one does not exist yet
            //------------------
            
            // create a new POI for anchor if an anchor does not exist
            SpaceToken *aToken = [[SpaceToken alloc] init];
            
            // Add the anchor to the map
            [self.mapView addSubview:aToken];
            [aToken configureAppearanceForType:ANCHORTOKEN];
            
            // Position the SpaceToken correctly
            aToken.center = mapXY;
            aToken.mapViewXY = mapXY;
            
            // Create a POI for the anchor
            POI* aPOI = [[POI alloc] init];
            aPOI.latLon = coord;
            aPOI.name = [NSString stringWithFormat:@"Anchor%d", counter++];
            aPOI.coordSpan = self.mapView.region.span;
            aToken.spatialEntity = aPOI;
            
            
            aToken.touch = aTouch;
            
            if (self.isSpaceTokenEnabled){
                [self.anchorSet addObject:aToken];
                [self.draggingSet addObject:aToken];
                [aToken showAnchorVisualIndicatorAfter:0];
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
            
            // Create a SpaceToken if the touch falls into the creation zone
            if (mapXY.x > 0.95 * self.mapView.frame.size.width){
                [self convertAnchorToRealToken:associatedToken];
            }else{
                // Position the SpaceToken correctly
                associatedToken.center = mapXY;
                associatedToken.mapViewXY = mapXY;
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

- (void) convertAnchorToRealToken: (SpaceToken*) token{
    // Create a new SpaceToken based on anchor
    
    [[[EntityDatabase sharedManager] entityArray] addObject:token.spatialEntity];
    
    self.isTokenCollectionViewEnabled = YES; // refresh the token panel
    [self removeAnchor: token];
}

@end
