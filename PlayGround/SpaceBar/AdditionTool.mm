//
//  AdditionTool.m
//  SpaceBar
//
//  Created by Daniel on 1/13/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "AdditionTool.h"

#import "SpaceBar.h"
#import "TokenCollection.h"
#import "CustomMKMapView.h"
#import "Route.h"
#import "ViewController.h"
#import "TokenCollectionView.h"
#import "ArrayTool.h"

@implementation AdditionTool{
    CAShapeLayer *lineLayer; // shows the line connecting the SpaceToken and the actual location
    BOOL isLineLayerOn;
    NSMutableArray *touchHistory;
    BOOL probEnabled;
    // The prob needs to be turn off once a token is added. This is to avoid duplicate additions.
}


-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.multipleTouchEnabled = YES;
    
    // Instantiate instance variables
    probEnabled = NO;
    isLineLayerOn = NO;
    lineLayer = [CAShapeLayer layer];
    
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    // Also need to check if any of the tokens in the parent view is touched.
    NSArray *tokenArray = [[TokenCollection sharedManager] getTokenArray];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.home == %@",
                              self.home];
    NSArray *filteredArray = [tokenArray filteredArrayUsingPredicate:predicate];
    
    for (SpaceToken *token in filteredArray){
        CGPoint convertedPoint = [self convertPoint:point toView:token];
        if (CGRectContainsPoint(token.bounds, convertedPoint)){
            return NO;
        }
    }
    
    if (CGRectContainsPoint(self.bounds, point)){
        return YES;
    }else{
        return NO;
    }
}

//-----------------
// MARK: Interactions
//-----------------
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    touchHistory = [NSMutableArray array];
    
    // Assuming there is only one touch
    UITouch *touch = [touches anyObject];
    probEnabled = YES;
    CGPoint touchPoint = [touch locationInView:self];
    [touchHistory addObject: [NSNumber valueWithCGPoint:touchPoint]];
}


- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    // Assuming there is only one touch
    UITouch *touch = [touches anyObject];

    if (!probEnabled){
        [self touchesEnded:touches withEvent:event];
        return;
    }
    
    // Check if the connection tool is activated
    if ([self probeRouteSource:touches]){
        [self touchesEnded:touches withEvent:event];
    }

}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self touchesEnded:touches withEvent:event];
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [lineLayer removeFromSuperlayer];
    touchHistory = nil;
}

//-----------------
// Connection tools
//-----------------

- (BOOL)probeRouteSource:(NSSet<UITouch *> *)touches{
    
    static BOOL movingOut = false;
    static CGPoint initOutLocation;
    
    // This only works when a single point is touched
    if ([touches count] > 1)
        return NO;
    
    UITouch *touch = [touches anyObject];
    
    CGPoint currentLocation = [touch locationInView:self];
    CGPoint previousLocation = [[touchHistory lastObject] CGPointValue];
    
    
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    
    if (CGRectContainsPoint(self.bounds, previousLocation) &&
        !CGRectContainsPoint(self.bounds, currentLocation))
    {
        movingOut = YES;
        initOutLocation = previousLocation;
        
        // Add the line layer to mapView
        [[mapView layer] addSublayer: lineLayer];
    }else{
        [touchHistory addObject:[NSNumber valueWithCGPoint:currentLocation]];
        return NO;
    }
    
    // Draw the line
    if (movingOut){
        // Draw a line
        // draw the line
        UIBezierPath *linePath=[UIBezierPath bezierPath];
        
        // For the array tool, the initial point is always from the center of the tool
        if (self.home == [ArrayTool sharedManager]){
            initOutLocation.x = self.bounds.size.width/2;
        }
        
        [linePath moveToPoint: [self convertPoint:initOutLocation toView:mapView]];
        [linePath addLineToPoint: [self convertPoint:currentLocation toView:mapView]];
        
        lineLayer.path=linePath.CGPath;
        lineLayer.fillColor = nil;
        lineLayer.opacity = 1.0;
        lineLayer.lineWidth = 4.0f;
        lineLayer.strokeColor = [UIColor blueColor].CGColor;
    }
    
    // Check if the connection tool touch any route?
    // Get the TokenCollection object    
    
    CGPoint touchPoint = [self convertPoint:currentLocation toView:mapView];
    CGPoint previoustouchPoint = [self convertPoint:previousLocation toView:mapView];
    for (SpaceToken *aToken in [[TokenCollection sharedManager] getTokenArray]){
        
        // Convert buttonFrame to be in mapView
        CGRect buttonInMapView = [aToken.superview convertRect:aToken.frame toView:mapView];
        
        // Make sure the route creation tool is only triggered once
        if (CGRectContainsPoint(buttonInMapView, touchPoint)
            &&
            !CGRectContainsPoint(buttonInMapView, previoustouchPoint)
            && probEnabled)
        {
            if (!self.additionHandlingBlock)
                return NO;
            
            BOOL result = self.additionHandlingBlock(aToken);
            if (result){
                probEnabled = NO;
                [lineLayer removeFromSuperlayer];
                movingOut = NO;
            }
            
            return result;
        }
    }
    return NO;
}

@end
