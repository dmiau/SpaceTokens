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

#pragma mark --Order SpaceToken--


////----------------
//// order the POIs and SpaceTokens on the track
////----------------
//-(void) orderButtonArray{
//    // equally distribute the POIs
//    if ([self.tokenCollection.tokenArray count] == 0 || [self.touchingSet count] > 0){
//        // only reorder when the user is not touching a button
//        return;
//    }
//    
//    // Fill in mapXY
//    [self fillMapXYsForSet:self.tokenCollection.tokenArray];
//    
//    if (self.isAutoOrderSpaceTokenEnabled){
//        // Form a new set for sorting
//        NSMutableSet *allTokens = [NSMutableSet setWithArray:self.tokenCollection.tokenArray];
//        
//        // Take YouAreHere from the set (YouAreHere should be at the bottom)
//        [allTokens removeObject: self.youAreHere];
//        
//        //Sort the POIs (sort by block)
//        //http://stackoverflow.com/questions/12917886/nssortdescriptor-custom-comparison-on-multiple-keys-simultaneously
//        
//        NSArray *sortedArray =
//        [[allTokens allObjects]
//         sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
//             SpaceToken *first = (SpaceToken*)a;
//             SpaceToken *second = (SpaceToken*)b;
//             
//             if (first.mapViewXY.y < second.mapViewXY.y) {
//                 return NSOrderedAscending;
//             }
//             else if (first.mapViewXY.y > second.mapViewXY.y) {
//                 return NSOrderedDescending;
//             }else{
//                 // In the unlikely case that the two POIs have the same y
//                 if (first.mapViewXY.x < second.mapViewXY.x) {
//                     return NSOrderedAscending;
//                 }else if (first.mapViewXY.x > second.mapViewXY.x) {
//                     return NSOrderedDescending;
//                 }else{
//                     return NSOrderedSame;
//                 }
//             }
//         }];
//        
//        self.tokenCollection.tokenArray = [NSMutableArray arrayWithArray:sortedArray];
//        
//        if (self.isYouAreHereEnabled){
//            [self.tokenCollection.tokenArray addObject:self.youAreHere];
//        }
//    }
//    
//    //----------------
//    // Snap SpaceTokens to grid
//    //----------------
//    
//    // Place the sorted button on to the grid
//    CGFloat viewWidth = self.mapView.frame.size.width;
//    CGFloat barHeight = self.mapView.frame.size.height;
//    CGFloat gap = barHeight / ([self.tokenCollection.tokenArray count] + 1);
//    
//    // Position the SpaceToken and dots
//    for (int i = 0; i < [self.tokenCollection.tokenArray count]; i++){
//        SpaceToken *aToken = self.tokenCollection.tokenArray[i];
//        if (aToken.appearanceType == DOCKED){
//            aToken.frame = CGRectMake(viewWidth - aToken.frame.size.width,
//                                      gap * (i+1), aToken.frame.size.width,
//                                      aToken.frame.size.height);
//        }else{
//            // calculate the distance from self to the adjancent two
//            // SpaceTokens
//            
//        }
//    }
//}

#pragma mark --Add/remove SpaceToken--

//----------------
// remove all SpaceTokens
//----------------
- (void)removeAllSpaceTokens{

    [self resetInteractiveTokenStructures];
    
    for (SpaceToken* aToken in [self.tokenCollection getTokenArray]){
        [aToken removeFromSuperview];
    }
    [self.tokenCollection removeAllTokens];
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
        [[TokenCollection sharedManager] resetAnnotationColor];
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
