//
//  GestureEngine.m
//  NavTools
//
//  Created by Daniel on 8/2/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "GestureEngine.h"
#import "NavTools.h"
#import "TokenCollection.h"
#import "CustomMKMapView.h"
#import "Route.h"
#import "ViewController.h"
#import "TokenCollectionView.h"

@implementation GestureEngine{
    CAShapeLayer *lineLayer; // shows the line connecting the SpaceToken and the actual location
    BOOL isLineLayerOn;
}


//--------------------------------
// Initializations
//--------------------------------
- (id)initWithSpaceBar:(NavTools*) navTools{

    // Make the detection area bigger
    CGRect detectionFrame = navTools.frame;
    
    self = [super initWithFrame:detectionFrame];
    if (self) {
        
        // Enable multitouch control
        self.navTools = navTools;
        self.multipleTouchEnabled = YES;
        
        // Instantiate instance variables
        isLineLayerOn = NO;
        lineLayer = [CAShapeLayer layer];
    }
    return self;
}

//-----------------
// Interactions
//-----------------
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    NSLog(@"Touches began...");
}


- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    // Check if the connection tool is activated
    if ([self probeRouteSource:touches])
        return;
    
    // Check if the user tries to remove the current route from the bar tool
    if ([self checkRemoveGesture:touches]){
        return;
    }
    
    // Else, update the bar
    [self spaceTokenHitTest:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    NSLog(@"Touches cancelled...");
    [lineLayer removeFromSuperlayer];
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    NSLog(@"Touches ended...");
    [lineLayer removeFromSuperlayer];
}


- (void)spaceTokenHitTest:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    // Assume there is only one touch
    UITouch *aTouch = [touches anyObject];
    CGPoint touchPoint = [aTouch locationInView:self.navTools.mapView];
    CGPoint previoustouchPoint =
                [aTouch previousLocationInView:self.navTools.mapView];
    
    // Iterate over SpaceTokens and perform hittest
    for (SpaceToken *aToken in [self.navTools.tokenCollection getTokenArray]){
        
        CGRect buttonFrame = aToken.frame;
        if (CGRectContainsPoint(buttonFrame, touchPoint) &&
            !CGRectContainsPoint(buttonFrame, previoustouchPoint))
        {
            [aToken sendActionsForControlEvents:UIControlEventTouchDown];
        }
    }
}

//-----------------
// Connection tools
//-----------------

- (BOOL)probeRouteSource:(NSSet<UITouch *> *)touches{
    
    static CGPoint initOutLocation;
    static BOOL movingOut = false;
    // This only works when a single point is touched
    if ([touches count] > 1)
        return NO;
    
    UITouch *touch = [touches anyObject];
    
    CGPoint currentLocation = [touch locationInView:self];
    CGPoint previousLocation = [touch previousLocationInView:self];
    
    if (previousLocation.x < self.frame.size.width &&
        currentLocation.x > self.frame.size.width)
    {
        movingOut = YES;
        initOutLocation = previousLocation;
        [[self layer] addSublayer: lineLayer];
    }
    
    // Draw the line
    if (movingOut){
        // Draw a line
        // draw the line
        UIBezierPath *linePath=[UIBezierPath bezierPath];
        [linePath moveToPoint: initOutLocation];
        [linePath addLineToPoint: currentLocation];
        
        lineLayer.path=linePath.CGPath;
        lineLayer.fillColor = nil;
        lineLayer.opacity = 1.0;
        lineLayer.strokeColor = [UIColor blueColor].CGColor;
    }
    
    // Check if the connection tool touch any route?
    // Get the TokenCollection object
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    
    CGPoint touchPoint = [self convertPoint:currentLocation toView:mapView];
    CGPoint previoustouchPoint = [self convertPoint:previousLocation toView:mapView];
    for (SpaceToken *aToken in [[TokenCollection sharedManager] getTokenArray]){
        
        // Convert buttonFrame to be in mapView
        CGRect buttonInMapView = [aToken.superview convertRect:aToken.frame toView:mapView];
        
        // Make sure the route creation tool is only triggered once
        if (CGRectContainsPoint(buttonInMapView, touchPoint)
            &&
            !CGRectContainsPoint(buttonInMapView, previoustouchPoint))
        {
            

            
            // Connection tool only supports the connection to a POI
            if ([aToken.spatialEntity isKindOfClass:[Route class]])
            {
                // Flash the touched SpaceToken
                [aToken flashToken];
                
                Route *aRoute = (Route*)aToken.spatialEntity;
                // Load the route to the bar tool
                [[ViewController sharedManager] showRoute:aRoute
                                    zoomToOverview:NO];
                
                [lineLayer removeFromSuperlayer];
            }
            
            return YES;
        }
    }
    return NO;
}

- (BOOL)checkRemoveGesture:(NSSet<UITouch *> *)touches{
    // This only works when a single point is touched
    if ([touches count] > 1)
        return NO;
    
    UITouch *touch = [touches anyObject];
    
    CGPoint currentLocation = [touch locationInView:self];
    CGPoint previousLocation = [touch previousLocationInView:self];
    
    if (currentLocation.x < 5 && previousLocation.x > 5){
        // Remove the line
        self.navTools.activeRoute = nil;
        
        // Reset Spacebar
        [self.navTools resetSpaceBar];
        return YES;
    }else{
        return NO;
    }
}

@end
