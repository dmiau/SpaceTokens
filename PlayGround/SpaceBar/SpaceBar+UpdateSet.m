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
        [self.buttonArray addObject:aNotification.object];
    }else if (aNotification.name == AddToTouchingSetNotification){
        [self addTokenToTouchingSet:aNotification.object];
    }else if (aNotification.name == AddToDraggingSetNotification){
        
        // Empty touchingSet as soon as a SpaceToken is being dragged
        [self clearAllTouchedTokens];
        
        // remove from the display set
        SpaceToken *currentSpaceToken = aNotification.object;
        [self.buttonArray removeObject:currentSpaceToken];
        // Duplicate the button
        SpaceToken* newSpaceToken =
        [self addSpaceTokenFromPOI:currentSpaceToken.poi];
        newSpaceToken.frame = currentSpaceToken.frame;
        
        currentSpaceToken.counterPart = newSpaceToken;

        [self.draggingSet addObject:currentSpaceToken];
    }
}


- (void) removeFromSetBasedOnNotification: (NSNotification*) aNotification
{
//    NSLog(@"removeFromSetBasedOnNotification");
    
    // handle the notification based on event name
    if (aNotification.name == RemoveFromButtonArrayNotification){
        [self.buttonArray removeObject:aNotification.object];        
    }else if (aNotification.name == RemoveFromTouchingSetNotification){        
        [self removeTokenFromTouchingSet:aNotification.object];
    }else if (aNotification.name == RemoveFromDraggingSetNotification){
        [self.draggingSet removeObject:aNotification.object];
    }
}


#pragma mark --Order SpaceToken--

- (void) updateSpecialPOIs{
    self.mapCentroid.poi.latLon = self.mapView.centerCoordinate;
}


//----------------
// order the POIs and SpaceTokens on the track
//----------------
-(void) orderButtonArray{
    // equally distribute the POIs
    if ([self.buttonArray count] == 0 || [self.touchingSet count] > 0){
        // only reorder when the user is not touching a button
        return;
    }
    
    // Fill in mapXY
    [self fillMapXYsForSet:self.buttonArray];
    
    if (self.isAutoOrderSpaceTokenEnabled){
        // Form a new set for sorting
        NSMutableSet *allTokens = [NSMutableSet setWithArray:self.buttonArray];
        
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
        
        self.buttonArray = [NSMutableArray arrayWithArray:sortedArray];
        
        if (self.isYouAreHereEnabled){
            [self.buttonArray addObject:self.youAreHere];
        }
    }
    
    //----------------
    // Snap SpaceTokens to grid
    //----------------
    
    // Place the sorted button on to the grid
    CGFloat viewWidth = self.mapView.frame.size.width;
    CGFloat barHeight = self.mapView.frame.size.height;
    CGFloat gap = barHeight / ([self.buttonArray count] + 1);
    
    // Position the SpaceToken and dots
    for (int i = 0; i < [self.buttonArray count]; i++){
        SpaceToken *aToken = self.buttonArray[i];
        if (aToken.type == DOCKED){
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
- (SpaceToken*) addSpaceTokenFromPOI:(POI *)poi{
    
    SpaceToken *aSpaceToken = [[SpaceToken alloc] init];
    [aSpaceToken configureAppearanceForType:DOCKED];
    
    [aSpaceToken setTitle:poi.name forState:UIControlStateNormal];
    aSpaceToken.poi = poi;
    
    if (aSpaceToken){
        // Add to the canvas
        [self.mapView addSubview:aSpaceToken];
        [self.buttonArray addObject:aSpaceToken];
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
- (void)addSpaceTokensFromPOIArray: (NSMutableArray <POI*> *) poiArray{
    // Remove all SpaceTokens first
    [self removeAllSpaceTokens];
    
    self.poiArrayDataSource = poiArray;
    
    for (POI* aPOI in poiArray){
        
        // Only show the enabled ones
        if (aPOI.isEnabled){
            [self addSpaceTokenFromPOI:aPOI];
            // Add the annotation
            aPOI.isMapAnnotationEnabled = YES;
        }
    }

    // Add YouAreHere
    if (self.isYouAreHereEnabled){
        // Initialize YouAreHere
        // Add a YouAreHere SpaceToken
        POI *specialPOI = [[POI alloc] init];
        specialPOI.name = @"YouRHere";
        specialPOI.latLon = CLLocationCoordinate2DMake(40.807722, -73.964110);
        self.youAreHere = [self addSpaceTokenFromPOI:specialPOI];
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

    for (SpaceToken* aToken in self.buttonArray){
        [aToken removeFromSuperview];
    }

    [self.draggingSet removeAllObjects];
    [self clearAllTouchedTokens];
    [self.dotSet removeAllObjects];
    [self.buttonArray removeAllObjects];
}


//----------------
// TouchingSet managment
//----------------
- (void)addTokenToTouchingSet: (SpaceToken*) aToken
{
    if (self.privateTouchingSetTimer){
        [self.privateTouchingSetTimer invalidate];
        self.privateTouchingSetTimer = nil;
    }
    [self.touchingSet addObject:aToken];
    self.privateTouchingSetTimer = [NSTimer scheduledTimerWithTimeInterval:10
                                                         target:self
                                                       selector:@selector(setTimerAction)
                                                       userInfo:nil
                                                        repeats:NO];
}


- (void)removeTokenFromTouchingSet: (SpaceToken*) aToken
{
    
    if ([self.touchingSet count] >1){
        if (self.privateTouchingSetTimer){
            [self.privateTouchingSetTimer invalidate];
            self.privateTouchingSetTimer = nil;
        }
        
        self.privateTouchingSetTimer = [NSTimer scheduledTimerWithTimeInterval:10
                                                                        target:self
                                                                      selector:@selector(setTimerAction)
                                                                      userInfo:nil
                                                                       repeats:NO];
    }
    
    [self.touchingSet removeObject:aToken];
}


- (void)clearAllTouchedTokens{
    self.privateTouchingSetTimer = nil;
    for (SpaceToken* aToken in self.touchingSet){
        aToken.selected = NO;
    }
    [self.touchingSet removeAllObjects];
}

- (void) setTimerAction{
//    [self clearAllTouchedTokens];
}

@end
