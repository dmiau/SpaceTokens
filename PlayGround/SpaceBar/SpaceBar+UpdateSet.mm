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
#import "Route.h"
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
        
        // remove from the display set
        SpaceToken *currentSpaceToken = aNotification.object;
        [self.tokenCollection.tokenArray removeObject:currentSpaceToken];
        // Duplicate the button
        SpaceToken* newSpaceToken =
        [self addSpaceTokenFromEntity:currentSpaceToken.spatialEntity];
        newSpaceToken.frame = currentSpaceToken.frame;
        
        currentSpaceToken.counterPart = newSpaceToken;

        // Enable the SpaceToken mode
        [self moveCandidateAnchorsToAnchorSet];
        [self.draggingSet addObject:currentSpaceToken];
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


//----------------
// order the POIs and SpaceTokens on the track
//----------------
-(void) orderButtonArray{
    // equally distribute the POIs
    if ([self.tokenCollection.tokenArray count] == 0 || [self.touchingSet count] > 0){
        // only reorder when the user is not touching a button
        return;
    }
    
    // Fill in mapXY
    [self fillMapXYsForSet:self.tokenCollection.tokenArray];
    
    if (self.isAutoOrderSpaceTokenEnabled){
        // Form a new set for sorting
        NSMutableSet *allTokens = [NSMutableSet setWithArray:self.tokenCollection.tokenArray];
        
        // Take YouAreHere from the set (YouAreHere should be at the bottom)
        [allTokens removeObject: self.youAreHere];
        
        //Sort the POIs (sort by block)
        //http://stackoverflow.com/questions/12917886/nssortdescriptor-custom-comparison-on-multiple-keys-simultaneously
        
        NSArray *sortedArray =
        [[allTokens allObjects]
         sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
             SpaceToken *first = (SpaceToken*)a;
             SpaceToken *second = (SpaceToken*)b;
             
             if (first.mapViewXY.y < second.mapViewXY.y) {
                 return NSOrderedAscending;
             }
             else if (first.mapViewXY.y > second.mapViewXY.y) {
                 return NSOrderedDescending;
             }else{
                 // In the unlikely case that the two POIs have the same y
                 if (first.mapViewXY.x < second.mapViewXY.x) {
                     return NSOrderedAscending;
                 }else if (first.mapViewXY.x > second.mapViewXY.x) {
                     return NSOrderedDescending;
                 }else{
                     return NSOrderedSame;
                 }
             }
         }];
        
        self.tokenCollection.tokenArray = [NSMutableArray arrayWithArray:sortedArray];
        
        if (self.isYouAreHereEnabled){
            [self.tokenCollection.tokenArray addObject:self.youAreHere];
        }
    }
    
    //----------------
    // Snap SpaceTokens to grid
    //----------------
    
    // Place the sorted button on to the grid
    CGFloat viewWidth = self.mapView.frame.size.width;
    CGFloat barHeight = self.mapView.frame.size.height;
    CGFloat gap = barHeight / ([self.tokenCollection.tokenArray count] + 1);
    
    // Position the SpaceToken and dots
    for (int i = 0; i < [self.tokenCollection.tokenArray count]; i++){
        SpaceToken *aToken = self.tokenCollection.tokenArray[i];
        if (aToken.appearanceType == DOCKED){
            aToken.frame = CGRectMake(viewWidth - aToken.frame.size.width,
                                      gap * (i+1), aToken.frame.size.width,
                                      aToken.frame.size.height);
        }else{
            // calculate the distance from self to the adjancent two
            // SpaceTokens
            
        }
    }
}

#pragma mark --Add/remove SpaceToken--

//----------------
// add a SpaceToken
//----------------
- (SpaceToken*) addSpaceTokenFromEntity:(SpatialEntity *)spatialEntity{
    
    // Depending on the type of spatialEntity, instantiate a corresponding spaceToken
    SpaceToken *aSpaceToken;
    if ([spatialEntity isKindOfClass:[POI class]]){
        aSpaceToken = [[SpaceToken alloc] init];
    }else if ([spatialEntity isKindOfClass:[Route class]]){
        aSpaceToken = [[PathToken alloc] init];
    }else{
        // error
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SpaceToken Error"
                                                        message:@"Unimplemented code path."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert show];
    }
    
    [aSpaceToken configureAppearanceForType:DOCKED];
    
    [aSpaceToken setTitle:spatialEntity.name forState:UIControlStateNormal];
    aSpaceToken.spatialEntity = spatialEntity;
    spatialEntity.linkedObj = aSpaceToken; // Establish the connection
    aSpaceToken.isDraggable = self.isTokenDraggingEnabled;
    
    if (aSpaceToken){
        // Add to the canvas
        [self.mapView addSubview:aSpaceToken];
        [self.tokenCollection.tokenArray addObject:aSpaceToken];
    }else{
        // error
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SpaceToken Error"
                                                        message:@"Cannot add new SpaceToken."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert show];
    }
    
    return aSpaceToken;
}

//----------------
// Add SpaceTokens from poiArray
//----------------
- (void)addSpaceTokensFromEntityArray: (NSMutableArray <SpatialEntity*> *) entityArray{
    // Remove all SpaceTokens first
    [self removeAllSpaceTokens];
    
    //-------------------------
    // Test the collection view
    //-------------------------
    float mapWidth = self.mapView.frame.size.width;
    float mapHeight = self.mapView.frame.size.height;
    
//    CGRect collectionViewFrame = CGRectMake(mapWidth - 60, 0, 60, mapHeight);
    
    self.tokenCollectionView.frame = self.mapView.frame;
    
    
//    // Add the collection view to the map view
//    [self.mapView addSubview:self.tokenCollectionViewController.view];
    
    ViewController *rootController = [ViewController sharedManager];
//    UIView *aView = [[UIView alloc] initWithFrame:rootController.view.frame];
//    [rootController.view addSubview:aView];
    [rootController.view addSubview:self.tokenCollectionView];

    return;
    
    //-------------------------
    // Original code
    //-------------------------
    for (SpatialEntity* anEntity in entityArray){
        
        // Only show the enabled ones
        if (anEntity.isEnabled){
            [self addSpaceTokenFromEntity:anEntity];
            // Add the annotation
            anEntity.isMapAnnotationEnabled = YES;
        }
    }

    // Add YouAreHere
    if (self.isYouAreHereEnabled){
        // Initialize YouAreHere
        // Add a YouAreHere SpaceToken
        POI *specialPOI = [[POI alloc] init];
        specialPOI.name = @"YouRHere";
        specialPOI.latLon = CLLocationCoordinate2DMake(40.807722, -73.964110);
        self.youAreHere = [self addSpaceTokenFromEntity:specialPOI];
        // Create a person
        Person *person = [[Person alloc] init];
        self.youAreHere.person = person;
    }
    [self orderButtonArray]; 
}

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
