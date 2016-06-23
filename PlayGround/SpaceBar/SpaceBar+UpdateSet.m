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
// add a SpaceMark
//----------------
- (SpaceMark*) addSpaceMarkWithName: (NSString*) name
                             LatLon: (CLLocationCoordinate2D) latlon{
    
    SpaceMark *aSpaceMark = [self.SpaceMarkArray Queue_dequeueReusableObjOfClass:@"SpaceMark"];
    [aSpaceMark resetButton];
    [aSpaceMark setTitle:name forState:UIControlStateNormal];
    aSpaceMark.latLon = latlon;
    
    if (aSpaceMark){
        // Add to the canvas
        [self.mapView addSubview:aSpaceMark];
        [self.buttonSet addObject:aSpaceMark];
    }else{
        // error
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SpaceMark Error"
                                                        message:@"Cannot add new SpaceMark."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert show];
    }
    
    return aSpaceMark;
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
        SpaceMark *currentSpaceMark = aNotification.object;
        [self.buttonSet removeObject:currentSpaceMark];
        // Duplicate the button
        SpaceMark* newSpaceMark = [self addSpaceMarkWithName: currentSpaceMark.titleLabel.text
                                                    LatLon:currentSpaceMark.latLon];
        currentSpaceMark.counterPart = newSpaceMark;

        [self.draggingSet addObject:currentSpaceMark];
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
// order the POIs and SpaceMarks on the track
//----------------
- (void) orderPOIs{
    // equally distribute the POIs
    if ([self.buttonSet count] > 0){
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

        // Position the SpaceMark and dots
        for (int i = 0; i < [sortedArray count]; i++){
            
            if ([sortedArray[i] isKindOfClass:[SpaceMark class]]){
                POI *aPOI = sortedArray[i];
                aPOI.frame = CGRectMake(viewWidth - aPOI.frame.size.width,
                                        gap * (i+1), aPOI.frame.size.width,
                                        aPOI.frame.size.height);
            }else{
                // calculate the distance from self to the adjancent two
                // SpaceMarks
                
            }
        }
        
    }
}

@end
