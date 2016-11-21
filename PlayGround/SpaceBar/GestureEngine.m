//
//  GestureEngine.m
//  SpaceBar
//
//  Created by Daniel on 8/2/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "GestureEngine.h"
#import "SpaceBar.h"

@implementation GestureEngine


//--------------------------------
// Initializations
//--------------------------------
- (id)initWithSpaceBar:(SpaceBar*) spaceBar{

    // Make the detection area bigger
    CGRect detectionFrame = spaceBar.frame;
    
    self = [super initWithFrame:detectionFrame];
    if (self) {
        
        // Enable multitouch control
        self.spaceBar = spaceBar;
        self.multipleTouchEnabled = YES;
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
//    NSLog(@"Touches moved...");
    [self spaceTokenHitTest:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    NSLog(@"Touches cancelled...");
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    NSLog(@"Touches ended...");
}


- (void)spaceTokenHitTest:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    // Assume there is only one touch
    UITouch *aTouch = [touches anyObject];
    CGPoint touchPoint = [aTouch locationInView:self.spaceBar.mapView];
    CGPoint previoustouchPoint =
                [aTouch previousLocationInView:self.spaceBar.mapView];
    
    // Iterate over SpaceTokens and perform hittest
    for (SpaceToken *aToken in self.spaceBar.buttonArray){
        
        CGRect buttonFrame = aToken.frame;
        if (CGRectContainsPoint(buttonFrame, touchPoint) &&
            !CGRectContainsPoint(buttonFrame, previoustouchPoint))
        {
            [aToken sendActionsForControlEvents:UIControlEventTouchDown];
        }
    }
}

// This method performs hitTest of all the SpaceToken and finds that one that is touched
- (SpaceToken*)findTouchedTokenFromTouch:(UITouch*)aTouch{
    SpaceToken *resultToken = nil;
    

    CGPoint touchPoint = [aTouch locationInView:self.spaceBar.mapView];
    CGPoint previoustouchPoint =
    [aTouch previousLocationInView:self.spaceBar.mapView];
    
    // Iterate over SpaceTokens and perform hittest
    for (SpaceToken *aToken in self.spaceBar.buttonArray){
        
        CGRect buttonFrame = aToken.frame;
        if (CGRectContainsPoint(buttonFrame, touchPoint))
        {
            resultToken = aToken;
        }
    }
    return resultToken;
}

@end
