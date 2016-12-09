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
    
    //    //detect swipe gestures
    //    UISwipeGestureRecognizer * swipeDown=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(buttonDown:)];
    //    swipeDown.direction=UISwipeGestureRecognizerDirectionDown;
    //    [self addGestureRecognizer:swipeDown];
    //
    //    UISwipeGestureRecognizer * swipeUp = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(buttonDown:)];
    //    swipeUp.direction=UISwipeGestureRecognizerDirectionUp;
    //    [self addGestureRecognizer:swipeUp];

    
//    UISwipeGestureRecognizer * swipeRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
//    swipeRight.direction=UISwipeGestureRecognizerDirectionRight;
//    [self addGestureRecognizer:swipeRight];
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

//-------------------
// SpaceToken is being dragged
//-------------------
- (void) buttonDragging:(UIButton *)sender forEvent: (UIEvent *)event {
    
    // Do nothing if the event is not triggered by self
    if (sender != self)
        return;
    
    // There could be multiple touch events!
    // Need to find the touch even associated with self
    UITouch *touch = nil;
    
    for (UITouch *aTouch in [event allTouches]){
        if ([aTouch view] == self)
            touch = aTouch;
    }
    
    CGPoint locationInView = [touch locationInView:self.superview];
    
    // Threshold the x position to distiguish wheather the button is dragged or clicked
    if ((self.superview.frame.size.width - locationInView.x) < self.frame.size.width*1.1)
    {
        // Do nothing if the SpaceMark is not dragged far out enough
        
        // Cancel the button if the touch is outside of the button
        if (locationInView.y < self.frame.origin.y
            || locationInView.y > self.frame.origin.y + self.frame.size.height)
        {
            [self buttonUp:self forEvent:nil];
            // If the touche moves outside of the button vertically, gesture engine should take over
            return;
        }
        
        // If the SpaceToken is dragged outside of the display, delete the SpaceToken
        if ((locationInView.x - initialTouchLocationInView.x) >
            self.frame.size.width/3)
        {
            
            if ([self.spatialEntity.name isEqualToString:@"YouRHere"]){
                // YouRHere cannot be removed.
            }else{
                [self handleRemoveToken];
            }
        }
        
    }else if (self.isDraggable){
        // handle the dragging event if the button is draggable
        [self handleDragToScreenAction:touch];
    }
}

//---------------
// Handle dragToScreen action
//---------------
- (void)handleDragToScreenAction: (UITouch *) touch{
    CGPoint locationInView = [touch locationInView:self.superview];
    CGPoint previousLoationInView = [touch previousLocationInView:self.superview];
    CGPoint locationInButton = [touch locationInView:self];
    
    if (!hasReportedDraggingEvent){
        // This is to make sure AddToDraggingSet notification is only sent once.
        hasReportedDraggingEvent = YES;
        [self.lineLayer removeFromSuperlayer];
        NSNotification *notification = [NSNotification notificationWithName:AddToDraggingSetNotification
                                                                     object:self userInfo:nil];
        [[ NSNotificationCenter defaultCenter] postNotification:notification];
        
        // Change the style of the dragging tocken
        [self configureAppearanceForType:DRAGGING];
    }
    
    // the button should be shifted so the center is coincided with the touch
    self.center = CGPointMake
    (self.center.x + locationInView.x - previousLoationInView.x
     - (self.frame.size.width/2 -locationInButton.x),
     self.center.y + locationInView.y - previousLoationInView.y
     - (self.frame.size.height/2 -locationInButton.y));
    
    if (self.counterPart &&
        (self.counterPart.center.x > self.superview.frame.size.width *0.5))
    {
        // draw the line
        UIBezierPath *linePath=[UIBezierPath bezierPath];
        [linePath moveToPoint: CGPointMake(self.frame.size.width/2,
                                           self.frame.size.height/2)];
        [linePath addLineToPoint:
         [self convertPoint:self.counterPart.center fromView:self.superview]];
        
        self.lineLayer.path=linePath.CGPath;
        self.lineLayer.fillColor = nil;
        self.lineLayer.opacity = 1.0;
        self.lineLayer.strokeColor = [UIColor blueColor].CGColor;
    }
}

//---------------
// Remove the SpaceToken
//---------------
- (void)handleRemoveToken{

    // Remove from the touching set
    [[ NSNotificationCenter defaultCenter] postNotification:
     [NSNotification notificationWithName:
      RemoveFromTouchingSetNotification object:self userInfo:nil]];
    
    [self removeFromSuperview];
    self.spatialEntity.isEnabled = NO;
    // Remove from the button set
    [[ NSNotificationCenter defaultCenter] postNotification:
     [NSNotification notificationWithName:RemoveFromButtonArrayNotification
                                   object:self userInfo:nil]];
}

@end
