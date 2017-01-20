//
//  SpaceBar+UpdateSet.m
//  SpaceBar
//
//  Created by dmiau on 2/13/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SpaceBar+UpdateSet.h"
#import "Constants.h"
#import "Tools.h"
#import "../Map/Person.h"
#import "PathToken.h"
#import "POI.h"
#import "Route.h"
#import "Person.h"
#import "TokenCollectionView.h"
#import "ViewController.h"
#import "TokenCollection.h"
#import "EntityDatabase.h"

@implementation SpaceBar (UpdateSet)

#pragma mark -- Handle notifications ---

//----------------
// notifications
//----------------
- (void) addToSetBasedOnNotification: (NSNotification*) aNotification
{
    // handle the notification based on event name
    if (aNotification.name == AddToTouchingSetNotification){
        // Enable the SpaceToken mode
        [self moveCandidateAnchorsToAnchorSet];
        [self addTokenToTouchingSet:aNotification.object];
    }else if (aNotification.name == AddToDraggingSetNotification){
        
        // Empty touchingSet as soon as a SpaceToken is being dragged
        [self clearAllTouchedTokens];

        // Enable the SpaceToken mode
        [self moveCandidateAnchorsToAnchorSet];
        [self.draggingSet addObject:aNotification.object];
    }
}

- (void)moveCandidateAnchorsToAnchorSet{
    
    // Skip this if anchor is disabled
    if (!self.isAnchorAllowed)
        return;
    
    // Need to use a temp set to enumertate the items in self.anchorCandidateSet
    // and then remove them from self.anchorCandidateSet
    NSSet *tempSet = [NSSet setWithSet:self.anchorCandidateSet];
    for (SpaceToken *aToken in tempSet){
        [self.anchorSet addObject:aToken];
        [self.draggingSet addObject:aToken];
        [self.anchorCandidateSet removeObject:aToken];
    }
    self.isSpaceTokenEnabled = YES;
}

- (void) removeFromSetBasedOnNotification: (NSNotification*) aNotification
{
    // handle the notification based on event name
    if (aNotification.name == RemoveFromTouchingSetNotification){        
        [self removeTokenFromTouchingSet:aNotification.object];
    }else if (aNotification.name == RemoveFromDraggingSetNotification){
        [self.draggingSet removeObject:aNotification.object];
    }
}

#pragma mark --Add/remove SpaceToken--

//----------------
// remove all SpaceTokens
//----------------
- (void)removeAllSpaceTokens{

    [self resetInteractiveTokenStructures];
    
    for (SpaceToken* aToken in [self.tokenCollection getTokenArray]){
        [aToken removeFromSuperview];
    }

}

// This clears draggingSet, anchor, and touchingSet
-(void)resetInteractiveTokenStructures{
    // destory all the dragged tokens
    for (SpaceToken* aToken in self.draggingSet){
        [aToken removeFromSuperview];
    }
    [self.draggingSet removeAllObjects];
    
    // destory all the anchors
    [self removeAllAnchors];
    
    // destory all the touched tokens
    [self clearAllTouchedTokens];
}

//----------------
// TouchingSet managment
//----------------
- (void)addTokenToTouchingSet: (SpaceToken*) aToken
{

    if (!self.isMultipleTokenSelectionEnabled){
        // Clear the touching set before adding new ones
        [self clearAllTouchedTokens];
    }
    
    if ([self.touchingSet count]==0){
        // reset the annotation
        [[TokenCollection sharedManager] resetAnnotations];
    }
    
    [self.touchingSet addObject:aToken];
}

- (void)removeTokenFromTouchingSet: (SpaceToken*) aToken
{
    [self.touchingSet removeObject:aToken];
}

- (void)clearAllTouchedTokens{
    for (SpaceToken* aToken in self.touchingSet){
        aToken.selected = NO;
    }
    
    [self.touchingSet removeAllObjects];
}

@end
