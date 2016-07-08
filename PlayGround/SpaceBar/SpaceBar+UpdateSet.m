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

@implementation SpaceBar (UpdateSet)

//----------------
// add a SpaceToken
//----------------
- (SpaceToken*) addSpaceTokenWithName: (NSString*) name
                             LatLon: (CLLocationCoordinate2D) latlon{
    
    SpaceToken *aSpaceToken = [self.SpaceTokenArray Queue_dequeueReusableObjOfClass:@"SpaceToken"];
    [aSpaceToken resetButton];
    [aSpaceToken setTitle:name forState:UIControlStateNormal];
    aSpaceToken.latLon = latlon;
    
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


- (void) addToSetBasedOnNotification: (NSNotification*) aNotification
{
    NSLog(@"addToSetBasedOnNotification");
    
    // handle the notification based on event name
    if (aNotification.name == AddToButtonSetNotification){
        [self.buttonSet addObject:aNotification.object];
    }else if (aNotification.name == AddToTouchingSetNotification){
        [self.touchingSet addObject:aNotification.object];
    }else if (aNotification.name == AddToDraggingSetNotification){
        
        // remove from the display set
        SpaceToken *currentSpaceToken = aNotification.object;
        [self.buttonSet removeObject:currentSpaceToken];
        // Duplicate the button
        SpaceToken* newSpaceToken = [self addSpaceTokenWithName: currentSpaceToken.titleLabel.text
            LatLon:currentSpaceToken.latLon];
        newSpaceToken.frame = currentSpaceToken.frame;
        
        currentSpaceToken.counterPart = newSpaceToken;

        [self.draggingSet addObject:currentSpaceToken];
    }
}


- (void) removeFromSetBasedOnNotification: (NSNotification*) aNotification
{
    NSLog(@"removeFromSetBasedOnNotification");
    
    // handle the notification based on event name
    if (aNotification.name == RemoveFromButtonSetNotification){
        [self.buttonSet removeObject:aNotification.object];
    }else if (aNotification.name == RemoveFromTouchingSetNotification){
        [self.draggingSet removeObject:aNotification.object];        
        [self.touchingSet removeObject:aNotification.object];
        
    }else if (aNotification.name == RemoveFromDraggingSetNotification){
        [self.draggingSet removeObject:aNotification.object];
    }
    
}

- (void) updateSpecialPOIs{
    self.mapCentroid.latLon = self.mapView.centerCoordinate;
}


//----------------
// order the POIs and SpaceTokens on the track
//----------------
- (void) orderPOIs{
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
        NSMutableSet *allPOIs = [NSMutableSet setWithSet:self.dotSet];
        [allPOIs unionSet: self.buttonSet];

        //Sort the POIs (sort by block)
        //http://stackoverflow.com/questions/12917886/nssortdescriptor-custom-comparison-on-multiple-keys-simultaneously
        
        NSArray *sortedArray =
        [[allPOIs allObjects]
         sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            POI *first = (POI*)a;
            POI *second = (POI*)b;
            
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
            
            if ([sortedArray[i] isKindOfClass:[SpaceToken class]]){
                POI *aPOI = sortedArray[i];
                aPOI.frame = CGRectMake(viewWidth - aPOI.frame.size.width,
                                        gap * (i+1), aPOI.frame.size.width,
                                        aPOI.frame.size.height);
            }else{
                // calculate the distance from self to the adjancent two
                // SpaceTokens
                
            }
        }
        
    }
}

@end
