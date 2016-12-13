//
//  ConnectionTool+Dragging.m
//  SpaceBar
//
//  Created by dmiau on 12/11/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "ConnectionTool+Dragging.h"
#import "SpaceToken.h"
#import "SpaceBar.h"
#import "TokenCollection.h"
#import "POI.h"
#import "Route.h"

#import "CustomMKMapView.h"


@implementation ConnectionTool (Dragging)


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
    
    if (self.isDraggable){
        
        // handle the dragging event if the button is draggable
        [self handleDragToScreenAction:touch];
    }
}

//---------------
// Handle dragToScreen action
//---------------
- (void)handleDragToScreenAction: (UITouch *) touch{
    
    //-----------------------
    // Visualize the behavior of the connection tool
    //-----------------------
    
    // Instantiate another connection tool if the current one is being dragged out
    if (!hasReportedDraggingEvent){
        hasReportedDraggingEvent = YES;
        self.translatesAutoresizingMaskIntoConstraints = YES;
        
        // Remove the old constraints
        [[CustomMKMapView sharedManager] removeConstraints: constraintsArray];
        
        // Create a new connection tool
        ConnectionTool *connectionTool = [[ConnectionTool alloc] init];
        [connectionTool attachToSpaceToken: counterPart];
        
        // Change the appearance
        [[self layer] addSublayer: lineLayer];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    
    CGPoint locationInView = [touch locationInView:self.superview];
    CGPoint previousLoationInView = [touch previousLocationInView:self.superview];
    CGPoint locationInButton = [touch locationInView:self];
    
    
    // the button should be shifted so the center is coincided with the touch
    self.center = CGPointMake
    (self.center.x + locationInView.x - previousLoationInView.x
     - (self.frame.size.width/2 -locationInButton.x),
     self.center.y + locationInView.y - previousLoationInView.y
     - (self.frame.size.height/2 -locationInButton.y));
    
    if (counterPart)
    {
        // draw the line
        UIBezierPath *linePath=[UIBezierPath bezierPath];
        [linePath moveToPoint: CGPointMake(self.frame.size.width/2,
                                           self.frame.size.height/2)];
        [linePath addLineToPoint:
         [self convertPoint:counterPart.center fromView:self.superview]];
        
        lineLayer.path=linePath.CGPath;
        lineLayer.fillColor = nil;
        lineLayer.opacity = 1.0;
        lineLayer.strokeColor = [UIColor blueColor].CGColor;
        
        
    }
    
    //-----------------------
    // Check if the tool tip touches anything
    //-----------------------
    [self connectionTipProbing:touch];
}

//-----------------------
// Check if the tool tip touches anything
//-----------------------
- (void)connectionTipProbing: (UITouch *) touch{
    
    static int cacheTouchAddress = 0;
    
    // Get the touch coordinates in mapView
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    CGPoint touchPoint = [touch locationInView:mapView];
    CGPoint previoustouchPoint =
    [touch previousLocationInView:mapView];
    
    //------------------------
    // Create a route when 3D touch is detected
    //------------------------
    if ([touch force] > 0.5 * [touch maximumPossibleForce]
        && cacheTouchAddress != (int)(size_t)touch)
    {
        // This is to make sure address look up happens once only
        cacheTouchAddress = (int)(size_t)touch;
        
        // Create a spatial entity for the destination
        POI *destinationPOI = [[POI alloc] init];
        destinationPOI.latLon = [mapView convertPoint:touchPoint toCoordinateFromView:mapView];
        
        // Create a route
        POI *sourcePOI = counterPart.spatialEntity;
        
        [Route addRouteWithSource:sourcePOI Destination:destinationPOI];
        
        [self removeFromSuperview];
        return;
    }
    
    
    //------------------------
    // Else, check if the connection tool touches any of the SpaceTokens
    //------------------------
    SpaceToken *resultToken = nil;
    
    // Get the TokenCollection object
    TokenCollection *tokenCollection = [TokenCollection sharedManager];
    

    
    for (SpaceToken *aToken in tokenCollection.tokenArray){
        
        // Convert buttonFrame to be in mapView
        CGRect buttonInMapView = [aToken.superview convertRect:aToken.frame toView:mapView];
        
        // Make sure the route creation tool is only triggered once
        if (CGRectContainsPoint(buttonInMapView, touchPoint)
            &&
            !CGRectContainsPoint(buttonInMapView, previoustouchPoint))
        {            
            // Connection tool only supports the connection of POI
            
            if ([aToken.spatialEntity isKindOfClass:[POI class]] &&
                [counterPart.spatialEntity isKindOfClass:[POI class]])
            {
                NSLog(@"SpaceToken: %@ tapped.", aToken.spatialEntity.name);
                
                // Flash the touched SpaceToken
                [aToken flashToken];
                
                // Create a route
                POI *sourcePOI = counterPart.spatialEntity;
                POI *destinationPOI = aToken.spatialEntity;
                [Route addRouteWithSource:sourcePOI Destination:destinationPOI];
                
                [self removeFromSuperview];

            }
            
            break;
        }
    }
}

@end
