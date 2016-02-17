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
        [self.canvas addSubview:aSpaceMark];
        [self.displaySet addObject:aSpaceMark];
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
    if (aNotification.name == AddToDisplaySetNotification){
        [self.displaySet addObject:aNotification.object];
    }else if (aNotification.name == AddToTouchingSetNotification){
        [self.touchingSet addObject:aNotification.object];
    }else if (aNotification.name == AddToDraggingSetNotification){
        
        POI *aPOI = aNotification.object;
        NSNotification *notification = [NSNotification notificationWithName:RemoveFromDisplaySetNotification
                                                                     object:aPOI userInfo:nil];
        [[ NSNotificationCenter defaultCenter] postNotification:notification];
        
        // Duplicate the button
        [self addSpaceMarkWithName: aPOI.titleLabel.text LatLon:aPOI.latLon];

        [self.draggingSet addObject:aPOI];
    }
}


- (void) removeFromSetBasedOnNotification: (NSNotification*) aNotification
{
    NSLog(@"removeFromSetBasedOnNotification");
    
    // handle the notification based on event name
    if (aNotification.name == RemoveFromDisplaySetNotification){
        [self.displaySet removeObject:aNotification.object];
    }else if (aNotification.name == RemoveFromTouchingSetNotification){
        [self.draggingSet removeObject:aNotification.object];        
        [self.touchingSet removeObject:aNotification.object];
        
    }else if (aNotification.name == RemoveFromDraggingSetNotification){
        [self.draggingSet removeObject:aNotification.object];
    }
    
}


//----------------
// order the POIs and SpaceMarks on the track
//----------------
- (void) orderPOIs{
    //    // count the number of POIs on the track
    //    NSPredicate *aPredicate = [NSPredicate predicateWithFormat:
    //                               @"self.superview != nil"];
    //
    //    NSArray *visibleSpaceMarks = [self.SpaceMarkArray filteredArrayUsingPredicate:aPredicate];
    
    //TODO: this function needs to be refactored later
    
    // equally distribute the POIs
    if ([self.displaySet count] > 0){
        CGFloat barHeight = self.mapView.frame.size.height;
        CGFloat viewWidth = self.mapView.frame.size.width;
        
        CGFloat gap = barHeight / ([self.displaySet count] + 1);
        
        int i = 0;
        for (POI *aPOI in self.displaySet){
            aPOI.frame = CGRectMake(viewWidth - aPOI.frame.size.width,
                                    gap * (i+1), aPOI.frame.size.width,
                                    aPOI.frame.size.height);
            i++;
        }
    }
}

@end
