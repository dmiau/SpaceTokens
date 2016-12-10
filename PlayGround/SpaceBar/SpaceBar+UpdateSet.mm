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


@implementation SpaceBar (UpdateSet)

#pragma mark -- Handle notifications ---

//----------------
// notifications
//----------------
- (void) addToSetBasedOnNotification: (NSNotification*) aNotification
{
//    NSLog(@"addToSetBasedOnNotification");
    
    // handle the notification based on event name
    if (aNotification.name == AddToButtonArrayNotification){
        [self.tokenCollection.tokenArray addObject:aNotification.object];
    }else if (aNotification.name == AddToTouchingSetNotification){
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
    for (SpaceToken *aToken in self.anchorCandidateSet){
        [self.anchorSet addObject:aToken];
        [self.draggingSet addObject:aToken];
        [self.anchorCandidateSet removeObject:aToken];
    }
    self.isSpaceTokenEnabled = YES;
}

- (void) removeFromSetBasedOnNotification: (NSNotification*) aNotification
{
//    NSLog(@"removeFromSetBasedOnNotification");
    
    // handle the notification based on event name
    if (aNotification.name == RemoveFromButtonArrayNotification){
        [self.tokenCollection.tokenArray removeObject:aNotification.object];        
    }else if (aNotification.name == RemoveFromTouchingSetNotification){        
        [self removeTokenFromTouchingSet:aNotification.object];
    }else if (aNotification.name == RemoveFromDraggingSetNotification){
        [self.draggingSet removeObject:aNotification.object];
    }
}

#pragma mark --Order SpaceToken--

- (void) updateSpecialPOIs{
    self.mapCentroid.spatialEntity.latLon = self.mapView.centerCoordinate;
}


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

    
    // destory all the SpaceTokens
    for (SpaceToken* aToken in self.draggingSet){
        [aToken removeFromSuperview];
    }
    
    for (SpaceToken* aToken in self.dotSet){
        [aToken removeFromSuperview];
    }

    for (SpaceToken* aToken in self.tokenCollection.tokenArray){
        [aToken removeFromSuperview];
    }
    
    [self removeAllAnchors];
    [self.draggingSet removeAllObjects];
    [self clearAllTouchedTokens];
    [self.dotSet removeAllObjects];
    [self.tokenCollection.tokenArray removeAllObjects];
}


//----------------
// TouchingSet managment
//----------------
- (void)addTokenToTouchingSet: (SpaceToken*) aToken
{
    if (privateTouchingSetTimer){
        [privateTouchingSetTimer invalidate];
        privateTouchingSetTimer = nil;
    }
    [self.touchingSet addObject:aToken];
    privateTouchingSetTimer = [NSTimer scheduledTimerWithTimeInterval:10
                                                         target:self
                                                       selector:@selector(setTimerAction)
                                                       userInfo:nil
                                                        repeats:NO];
}


- (void)removeTokenFromTouchingSet: (SpaceToken*) aToken
{
    
    if ([self.touchingSet count] >1){
        if (privateTouchingSetTimer){
            [privateTouchingSetTimer invalidate];
            privateTouchingSetTimer = nil;
        }
        
        privateTouchingSetTimer = [NSTimer scheduledTimerWithTimeInterval:10
                                                                        target:self
                                                                      selector:@selector(setTimerAction)
                                                                      userInfo:nil
                                                                       repeats:NO];
    }
    
    [self.touchingSet removeObject:aToken];
}


- (void)clearAllTouchedTokens{
    privateTouchingSetTimer = nil;
    for (SpaceToken* aToken in self.touchingSet){
        aToken.selected = NO;
    }
    [self.touchingSet removeAllObjects];
}

- (void) setTimerAction{
//    [self clearAllTouchedTokens];
}

@end
