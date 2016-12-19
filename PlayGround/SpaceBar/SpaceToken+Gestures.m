//
//  SpaceToken+Gestures.m
//  SpaceBar
//
//  Created by dmiau on 8/25/16.
//  Copyright © 2016 dmiau. All rights reserved.
//
#import "Constants.h"
#import "SpaceToken+Gestures.h"
#import "WildcardGestureRecognizer.h"

@implementation SpaceToken (Gestures)

- (void) registerButtonEvents{
    
//    [self addTarget:self
//             action:@selector(buttonDown: forEvent:)
//   forControlEvents:UIControlEventTouchDown];
//
//    [self addTarget:self
//             action:@selector(buttonUp: forEvent:)
//   forControlEvents:UIControlEventTouchUpInside];
//    
//    
//    [self addTarget:self
//             action:@selector(buttonDragging: forEvent:)
//   forControlEvents:UIControlEventTouchDragInside];
    
    //-----------------
    // Initialize custom gesture recognizer
    //-----------------
    
    // Q: Why do I need to use a custom gesture recognizer?
    // A1: Because I need to disable the default rotation gesture recognizer
    // A2: I don't want my touch to be cancelled by other gesture recognizer
    // (http://stackoverflow.com/questions/5818692/how-to-avoid-touches-cancelled-event)
    
    WildcardGestureRecognizer * tapInterceptor = [[WildcardGestureRecognizer alloc] init];
    
    tapInterceptor.touchesBeganCallback = ^(NSSet<UITouch*>* touches, UIEvent * event) {
        [self customTouchesBegan:touches withEvent:event];
    };
    
    tapInterceptor.touchesEndedCallback = ^(NSSet<UITouch*>* touches, UIEvent * event) {
        [self customTouchesEnded:touches withEvent:event];
    };
    
    tapInterceptor.touchesMovedCallback = ^(NSSet<UITouch*>* touches, UIEvent * event) {
        [self customTouchesMoved:touches withEvent:event];
    };
    
    tapInterceptor.touchesCancelledCallback = ^(NSSet<UITouch*>* touches, UIEvent * event) {
        [self customTouchesCancelled:touches withEvent:event];
    };
    
    tapInterceptor.delegate = self;
    
    [self addGestureRecognizer:tapInterceptor];
}


//-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    return YES;
//}


- (void) buttonDown:(UIButton*) sender forEvent:(UIEvent*)event {
    
    hasReportedDraggingEvent = NO;
    
    if (self.selected){
        self.selected = NO;
        
        NSNotification *notification = [NSNotification notificationWithName:RemoveFromTouchingSetNotification
                                                                     object:self userInfo:nil];
        [[ NSNotificationCenter defaultCenter] postNotification:notification];
        self.spatialEntity.annotation.isHighlighted = NO;
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
        self.spatialEntity.annotation.isHighlighted = YES;
    }
    // Forced refresh the annotation color
    self.spatialEntity.isMapAnnotationEnabled = NO;
    self.spatialEntity.isMapAnnotationEnabled = YES;
}

- (void) buttonUp:(UIButton*) sender forEvent:(UIEvent*)event {
}

- (void) buttonDragging:(UIButton*) sender forEvent:(UIEvent*)event {
    self.isCustomGestureRecognizerEnabled = YES;
}

-(void) customTouchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if (!self.isCustomGestureRecognizerEnabled)
        return;
    
    // There could be multiple touch events!
    // Need to find the touch even associated with self
    UITouch *touch = nil;
    for (UITouch *aTouch in touches){
        if ([aTouch view] == self)
            touch = aTouch;
    }
    
    hasReportedDraggingEvent = NO;
    
    if (self.selected){
        self.selected = NO;
        
        NSNotification *notification = [NSNotification notificationWithName:RemoveFromTouchingSetNotification
                                                                     object:self userInfo:nil];
        [[ NSNotificationCenter defaultCenter] postNotification:notification];
        self.spatialEntity.annotation.isHighlighted = NO;
        
    }else{
        self.selected = YES;
        
        //--------------
        // SpaceToken is being turned on
        //--------------
        
        // Cache the initial button down location
        initialTouchLocationInView = [touch locationInView:self.superview];
        
        NSNotification *notification = [NSNotification notificationWithName:AddToTouchingSetNotification
                                                                     object:self userInfo:nil];
        [[ NSNotificationCenter defaultCenter] postNotification:notification];
        
        //--------------
        // Highlight the SpatialEntity
        //--------------
        self.spatialEntity.annotation.isHighlighted = YES;
    }
    
    // Forced refresh the annotation color
    self.spatialEntity.isMapAnnotationEnabled = NO;
    self.spatialEntity.isMapAnnotationEnabled = YES;
}

-(void)customTouchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!self.isCustomGestureRecognizerEnabled)
        return;
    
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
    }
}

-(void)customTouchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!self.isCustomGestureRecognizerEnabled)
        return;
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
    }
}

@end
