//
//  SpaceToken+Gestures.m
//  SpaceBar
//
//  Created by dmiau on 8/25/16.
//  Copyright © 2016 dmiau. All rights reserved.
//
#import "Constants.h"
#import "SpaceToken+Gestures.h"

@implementation SpaceToken (Gestures)

- (void) registerButtonEvents{
    [self addTarget:self
             action:@selector(buttonDown: forEvent:)
   forControlEvents:UIControlEventTouchDown];
    
    //    [self addTarget:self
    //             action:@selector(buttonDown:)
    //   forControlEvents:UIControlEventTouchDragEnter];
    
    
    [self addTarget:self
             action:@selector(buttonUp: forEvent:)
   forControlEvents:UIControlEventTouchUpInside];
    
    
    [self addTarget:self
             action:@selector(buttonDragging: forEvent:)
   forControlEvents:UIControlEventTouchDragInside];
}


//-----------
// button methods
//-----------
- (void) buttonDown:(UIButton*) sender forEvent:(UIEvent*)event {        
    // Do nothing if the event is not triggered by self
    if (sender != self || self.appearanceType !=DOCKED)
        return;
    
    //    NSLog(@"Touch down!");
    hasReportedDraggingEvent = NO;
    
    if (self.selected){
        self.selected = NO;

        NSNotification *notification = [NSNotification notificationWithName:RemoveFromTouchingSetNotification
                                                                     object:self userInfo:nil];
        [[ NSNotificationCenter defaultCenter] postNotification:notification];
    }else{
        self.selected = YES;

        //--------------
        // SpaceToken is being turned on
        //--------------
        
        // There could be multiple touch events!
        // Need to find the touch even associated with self
        UITouch *touch = nil;
        for (UITouch *aTouch in [event allTouches]){
            if ([aTouch view] == self)
                touch = aTouch;
        }
        // Cache the initial button down location
        initialTouchLocationInView = [touch locationInView:self.superview];
        
        NSNotification *notification = [NSNotification notificationWithName:AddToTouchingSetNotification
                                                                     object:self userInfo:nil];
        [[ NSNotificationCenter defaultCenter] postNotification:notification];
        
        //--------------
        // Highlight the SpatialEntity
        //--------------
        self.spatialEntity.annotation.pointType = RED_LANDMARK;
        
        // Forced refresh the annotation color
        self.spatialEntity.isMapAnnotationEnabled = NO;
        self.spatialEntity.isMapAnnotationEnabled = YES;
    }
}

- (void) buttonUp:(UIButton*)sender forEvent:(UIEvent*)event{
    
    // Do nothing if the event is not triggered by self
    if (sender != self)
        return;
    
    //    NSLog(@"Touch up!");
    if (hasReportedDraggingEvent){
        //------------------------
        // The button was dragged.
        //------------------------
        hasReportedDraggingEvent = NO;
        [self.lineLayer removeFromSuperlayer];
        [self removeFromSuperview];
        NSNotification *notification = [NSNotification notificationWithName:RemoveFromDraggingSetNotification
                                                                     object:self userInfo:nil];
        [[ NSNotificationCenter defaultCenter] postNotification:notification];
    }else{
        //------------------------
        // The button was touched.
        //------------------------
        //        NSNotification *notification = [NSNotification notificationWithName:RemoveFromTouchingSetNotification
        //                                                                     object:self userInfo:nil];
        //        [[ NSNotificationCenter defaultCenter] postNotification:notification];
    }
}





@end
