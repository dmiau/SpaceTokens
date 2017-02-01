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

//-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    return YES;
//}



//-------------------
// Initialize gesture recognizer
//-------------------
-(void)initializeGestureRecognizer{
    //-----------------
    // Initialize custom gesture recognizer
    //-----------------
    
    // Q: Why do I need to use a custom gesture recognizer?
    // A1: Because I need to disable the default rotation gesture recognizer
    // A2: I don't want my touch to be cancelled by other gesture recognizer
    // (http://stackoverflow.com/questions/5818692/how-to-avoid-touches-cancelled-event)
    
    tapInterceptor = [[WildcardGestureRecognizer alloc] init];
    
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
}

//-------------------
// Add button actions
//-------------------
-(void)addButtonActions{
        [self addTarget:self
                 action:@selector(buttonDown: forEvent:)
       forControlEvents:UIControlEventTouchDown];
    
        [self addTarget:self
                 action:@selector(buttonUp: forEvent:)
       forControlEvents:UIControlEventTouchUpInside];
    
        [self addTarget:self
                 action:@selector(buttonUp: forEvent:)
       forControlEvents:UIControlEventTouchCancel];
    
        [self addTarget:self
                 action:@selector(buttonUp: forEvent:)
       forControlEvents:UIControlEventTouchUpOutside];
    
        [self addTarget:self
                 action:@selector(buttonDragging: forEvent:)
       forControlEvents:UIControlEventTouchDragInside];
}

//-------------------
// Remove button actions
//-------------------
-(void)removeButtonActions{
    [self removeTarget:nil
             action:NULL
   forControlEvents:UIControlEventTouchDown];
    
    [self removeTarget:nil
             action:NULL
   forControlEvents:UIControlEventTouchUpInside];
    
    [self removeTarget:nil
             action:NULL
   forControlEvents:UIControlEventTouchCancel];
    
    [self removeTarget:nil
             action:NULL
   forControlEvents:UIControlEventTouchUpOutside];
    
    [self removeTarget:nil
             action:NULL
   forControlEvents:UIControlEventTouchDragInside];
}

#pragma mark -- UIControl methods --

- (void) buttonDown:(UIButton*) sender forEvent:(UIEvent*)event {
    
    // There could be multiple touch events!
    // Need to find the touch even associated with self
    UITouch *touch = nil;
    for (UITouch *aTouch in [event allTouches]){
        if ([aTouch view] == self)
            touch = aTouch;
    }
    [self touchBegan:touch];
}

- (void) buttonUp:(UIButton*) sender forEvent:(UIEvent*)event {
    // There could be multiple touch events!
    // Need to find the touch even associated with self
    UITouch *touch = nil;
    for (UITouch *aTouch in [event allTouches]){
        if ([aTouch view] == self)
            touch = aTouch;
    }
    [self touchEnded];
}

- (void) buttonDragging:(UIButton*) sender forEvent:(UIEvent*)event {
    // There could be multiple touch events!
    // Need to find the touch even associated with self
    UITouch *touch = nil;
    for (UITouch *aTouch in [event allTouches]){
        if ([aTouch view] == self)
            touch = aTouch;
    }
    [self touchMoved:touch];
}

#pragma mark -- Gesture methods --
-(void) customTouchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [super touchesBegan:touches withEvent:event];

    // There could be multiple touch events!
    // Need to find the touch even associated with self
    UITouch *touch = nil;
    for (UITouch *aTouch in touches){
        if ([aTouch view] == self)
            touch = aTouch;
    }
    [self touchBegan:touch];
}

-(void)customTouchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self touchEnded];
}

-(void)customTouchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self touchEnded];
}


#pragma mark -- Common touch methods --

-(void)touchBegan:(UITouch*)touch{
    
    static int touchAddress = 0;
    // Each touch should only trigger touchBegan once
    if (touchAddress != (int)touch){
        touchAddress = (int)touch;
    }else{
        return;
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
}

- (void)touchEnded{

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
