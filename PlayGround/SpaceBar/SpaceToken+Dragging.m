//
//  SpaceToken+Dragging.m
//  SpaceBar
//
//  Created by Daniel on 12/9/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SpaceToken+Dragging.h"
#import "Constants.h"
#import "TokenCollectionView.h"
#import "TokenCollection.h"
#import "ConnectionTool.h"
#import "CustomMKMapView.h"

@implementation SpaceToken (Dragging)
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
        //----------------------
        // Dragging toward the edge (removing gesture)
        //----------------------
        
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
        //----------------------
        // Dragging away from the edge (dragging gesture)
        //----------------------
        
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

        [self convertSelfToClone];
        
        NSNotification *notification = [NSNotification notificationWithName:AddToDraggingSetNotification
            object:self userInfo:nil];
        [[ NSNotificationCenter defaultCenter] postNotification:notification];
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
// Convert the current token to become a clone
//---------------
- (void)convertSelfToClone{
    
    // A dragging token should not be selected
    self.selected = NO;
    
    //------------------
    // Create a SpaceToken at the original position
    //------------------
    SpaceToken* newSpaceToken = [self copy];
    // Connect the plumbing of the new token
    [self.superview addSubview:newSpaceToken];
    newSpaceToken.frame = self.frame;
    self.counterPart = newSpaceToken;
    
    // Add the token to TokenCollection
    [[[TokenCollection sharedManager] tokenArray] addObject:newSpaceToken];
    
    // Remove the current token from TokenCollection
    [[[TokenCollection sharedManager] tokenArray] removeObject:self];
    
    //------------------
    // Attach SpaceToken to mapView, as opposed to TokenCell
    //------------------
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    // Update the origin
    self.center = [self.superview convertPoint:self.center
                                        toView:mapView];
    [mapView addSubview:self];
    
    // Change the style of the dragging tocken
    [self configureAppearanceForType:DRAGGING];
    
    
    
}


//-------------------
// Configure the token as a dragging token
//-------------------
- (void)privateConfigureDraggingTokenAppearance{
    self.selected = NO;
    [self setBackgroundColor:[UIColor clearColor]];
    
    [self.titleLabel removeFromSuperview];
    
    // Draw a circle under the centroid of the button
    float radius = 30;
    [self.circleLayer setStrokeColor:[[UIColor blueColor] CGColor]];
    [self.circleLayer setFillColor:[[UIColor clearColor] CGColor]];
    [self.circleLayer setPath:[[UIBezierPath
                                bezierPathWithOvalInRect:
                                CGRectMake(-radius + self.frame.size.width/2, -radius + self.frame.size.height/2, 2*radius, 2*radius)]
                               CGPath]];
    
    [[self layer] addSublayer:self.circleLayer];
    
    //--------------------
    // Add a connection tool on top of the circle
    //--------------------
    ConnectionTool *connectionTool = [[ConnectionTool alloc] init];
    [connectionTool attachToSpaceToken: self];
//    [connectionTool setHidden:YES]; // Connection tool is hidden by default
}

- (void)privateConfigureAnchorAppearanceVisible:(BOOL)visibleFlag{
    
    TokenAppearanceType targetType = visibleFlag? ANCHOR_VISIBLE : ANCHOR_INVISIBLE;
    
    if (self.appearanceType == targetType)
        return; // do nothing if the current type is equal to the target type
    
    // This decides whether the token was dragged from the sidebar or not
    if (self.appearanceType != ANCHOR_INVISIBLE &&
        self.appearanceType != ANCHOR_VISIBLE)
    {
        [self privateConfigureDraggingTokenAppearance];
        hasReportedDraggingEvent = YES;
    }
    
    
    // This decides the visual appearance of the anchor
    if (targetType == ANCHOR_VISIBLE){
        self.isLineLayerOn = NO;
        self.isCircleLayerOn = YES;
        [self.connectionTool setHidden:NO];
    }else{
        self.isLineLayerOn = NO;
        self.isCircleLayerOn = NO;
        [self.connectionTool setHidden:YES];
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
