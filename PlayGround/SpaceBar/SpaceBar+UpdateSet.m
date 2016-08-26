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

//----------------
// add a SpaceToken
//----------------
- (SpaceToken*) addSpaceTokenFromPOI:(POI *)poi{
    
    SpaceToken *aSpaceToken = [[SpaceToken alloc] initForType:DOCKED];
    
    [aSpaceToken setTitle:poi.name forState:UIControlStateNormal];
    aSpaceToken.poi = poi;
    
    if (aSpaceToken){
        // Add to the canvas
        [self.mapView addSubview:aSpaceToken];
        [self.buttonSet addObject:aSpaceToken];
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
// notifications
//----------------
- (void) addToSetBasedOnNotification: (NSNotification*) aNotification
{
//    NSLog(@"addToSetBasedOnNotification");
    
    // handle the notification based on event name
    if (aNotification.name == AddToButtonSetNotification){
        [self.buttonSet addObject:aNotification.object];
    }else if (aNotification.name == AddToTouchingSetNotification){
        [self addTokenToTouchingSet:aNotification.object];
    }else if (aNotification.name == AddToDraggingSetNotification){
        
        // Empty touchingSet as soon as a SpaceToken is being dragged
        [self clearAllTouchedTokens];
        
        // remove from the display set
        SpaceToken *currentSpaceToken = aNotification.object;
        [self.buttonSet removeObject:currentSpaceToken];
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
    if (aNotification.name == RemoveFromButtonSetNotification){
        [self.buttonSet removeObject:aNotification.object];
    }else if (aNotification.name == RemoveFromTouchingSetNotification){        
        [self removeTokenFromTouchingSet:aNotification.object];
    }else if (aNotification.name == RemoveFromDraggingSetNotification){
        [self.draggingSet removeObject:aNotification.object];
    }
}

- (void) updateSpecialPOIs{
    self.mapCentroid.poi.latLon = self.mapView.centerCoordinate;
}


//----------------
// order the POIs and SpaceTokens on the track
//----------------
- (void) orderSpaceTokens{
    // equally distribute the POIs
    // only reorder when the user is not touching a button
    if ([self.buttonSet count] > 0 && [self.touchingSet count] == 0)
    {
        CGFloat barHeight = self.mapView.frame.size.height;
        CGFloat viewWidth = self.mapView.frame.size.width;
        
        CGFloat gap = barHeight / ([self.buttonSet count] + 1);
        
        // Fill in mapXY
        [self fillMapXYsForSet:self.dotSet];
        [self fillMapXYsForSet:self.buttonSet];
        
        // Form a new set for sorting
        NSMutableSet *allTokens = [NSMutableSet setWithSet:self.dotSet];
        [allTokens unionSet: self.buttonSet];

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

        // Position the SpaceToken and dots
        for (int i = 0; i < [sortedArray count]; i++){
            SpaceToken *aToken = sortedArray[i];
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
}

//----------------
// Add SpaceTokens from poiArray
//----------------
- (void)addSpaceTokensFromPOIArray: (NSArray <POI*> *) poiArray{
    
    // Remove all SpaceTokens first
    [self removeAllSpaceTokens];
    
    for (POI* aPOI in poiArray){
        [self addSpaceTokenFromPOI:aPOI];
        
        // Add the annotation
        [self.mapView addAnnotation:aPOI.annotation];
    }
    
    // Add a YouAreHere SpaceToken
    POI *specialPOI = [[POI alloc] init];
    specialPOI.name = @"YouRHere";
    specialPOI.latLon = CLLocationCoordinate2DMake(40.807722, -73.964110);
    self.youAreHere = [self addSpaceTokenFromPOI:specialPOI];
        
    // Create a person
    Person *person = [[Person alloc] init];
    self.youAreHere.person = person;    
    [self orderSpaceTokens];
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

    for (SpaceToken* aToken in self.buttonSet){
        [aToken removeFromSuperview];
    }

    [self.draggingSet removeAllObjects];
    [self clearAllTouchedTokens];
    [self.dotSet removeAllObjects];
    [self.buttonSet removeAllObjects];
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
    self.privateTouchingSetTimer = [NSTimer scheduledTimerWithTimeInterval:1
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
        
        self.privateTouchingSetTimer = [NSTimer scheduledTimerWithTimeInterval:1
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
    [self clearAllTouchedTokens];
}

@end
