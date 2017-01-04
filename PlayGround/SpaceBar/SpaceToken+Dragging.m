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
#import "ArrayTool.h"
#import "ArrayEntity.h"

@implementation SpaceToken (Dragging)

-(void)touchMoved:(UITouch*)touch{
    // Do nothing if the button is not draggable
    if (!self.isDraggable)
        return;
    
    CGPoint locationInView = [touch locationInView:self];
    CGPoint previousLocationInView = [touch previousLocationInView:self];
    
    // Threshold the x position to distiguish wheather the button is dragged or clicked
    if (CGRectContainsPoint(self.frame, locationInView))
    {
        //----------------------
        // Removing gesture (Dragging toward the edge)
        //----------------------
        
        // Need to handle token removal detection differently,
        // depending on the position of a SpaceToken
        
        CustomMKMapView *mapView = [CustomMKMapView sharedManager];
        CGPoint tokenCenter = [self.superview convertPoint:self.center
                                                    toView:mapView];
        
        if (tokenCenter.x > mapView.frame.size.width/2){
            // SpaceToken is located at the right edge of the display
            
            if((initialTouchLocationInView.x < self.frame.size.width * 0.5)
               &&
               (previousLocationInView.x < self.frame.size.width *0.8 &&
                locationInView.x > self.frame.size.width *0.8)
               )
            {
                if ([self.spatialEntity.name isEqualToString:@"YouRHere"]){
                    // YouRHere cannot be removed.
                }else{
                    [self handleRemoveToken];
                }
            }
        }else{
            // SpaceToken is located at the left edge of the display
            
            if((initialTouchLocationInView.x > self.frame.size.width * 0.5)
               &&
               (previousLocationInView.x > self.frame.size.width *0.2 &&
                locationInView.x < self.frame.size.width *0.2)
               )
            {
                if ([self.spatialEntity.name isEqualToString:@"YouRHere"]){
                    // YouRHere cannot be removed.
                }else{
                    [self handleRemoveToken];
                }
            }
        }
        
    }else{
        //----------------------
        // Dragging away from the edge (dragging gesture)
        //----------------------
        
        // handle the dragging event if the button is draggable
        [self handleDragToScreenAction:touch];
    }
}



-(void)customTouchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    if (!self.isCustomGestureRecognizerEnabled)
        return;
    
    // There could be multiple touch events!
    // Need to find the touch even associated with self
    UITouch *touch = nil;
    
    for (UITouch *aTouch in touches){
        if ([aTouch view] == self)
            touch = aTouch;
    }
    [self touchMoved:touch];
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
    
    // Check if the token is to be inserted into any of the structure
    
    // Check if the token is in ArraTool's insertion zone
    ArrayTool *arrayTool = [ArrayTool sharedManager];
    
    if (self.home != arrayTool){
        if ([arrayTool isTouchInInsertionZone:touch]){
            NSLog(@"Insert from dragging");
            [arrayTool insertToken:self];
            [self touchEnded];
        }
    }
}


//---------------
// Convert the current token to become a clone
//---------------
- (void)convertSelfToClone{
    
    // Temporary disable the scrolling of TokenCollectionView
    // This is a hack to prevent the dragging gesture from
    // coupling with the scrolling gesture
    [[TokenCollectionView sharedManager] setScrollEnabled:NO];
    
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
    [[TokenCollection sharedManager] addToken:newSpaceToken];
    
    // Remove the current token from TokenCollection
    [[TokenCollection sharedManager] removeToken:self];
    
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
    
    [[TokenCollectionView sharedManager] setScrollEnabled:YES];
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
    
    //--------------------
    // User won't be able to remove a SpaceToken in the study
    //--------------------
    if (self.isStudyModeEnabled)
        return;
    
    self.isDraggable = NO;
    [self setBackgroundColor:[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:0.5]];
    
    //--------------------
    // Token will be removed after some time delay
    //--------------------
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Remove from the touching set
        [[ NSNotificationCenter defaultCenter] postNotification:
         [NSNotification notificationWithName:
          RemoveFromTouchingSetNotification object:self userInfo:nil]];
        
        [self removeFromSuperview];
        
        // Need to do things differently depending on the parent of the token
        ArrayTool *arrayTool = [ArrayTool sharedManager];
        
        if (self.home != arrayTool){
            // The parent is the dock
            self.spatialEntity.isEnabled = NO;
            self.spatialEntity.isMapAnnotationEnabled = NO;
            
            // Remove from the button set
            [[ NSNotificationCenter defaultCenter] postNotification:
             [NSNotification notificationWithName:RemoveFromButtonArrayNotification
                                           object:self userInfo:nil]];
        }else{
            // The parent is ArrayTool
            
            // TODO: Need to handle duplication
            [arrayTool.arrayEntity.contentArray removeObject:self.spatialEntity];
            [arrayTool reloadData];
        }
    });
}


//- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
//{
//    
//    if ([preventedGestureRecognizer.view isKindOfClass:[TokenCollectionView class]])
//    {
//        return YES;
//    }else{
//        return NO;
//    }
//}

@end
