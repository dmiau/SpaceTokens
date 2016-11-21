//
//  ConnectionTool.m
//  SpaceBar
//
//  Created by dmiau on 11/18/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "ConnectionTool.h"
#import "SpaceToken.h"
#import "CustomMKMapView.h"
#import "SpaceBar.h"
#import "TokenCollection.h"
#import "POI.h"
#import "Route.h"

#define CONNECTION_TOOL_WIDTH 100
#define CONNECTION_TOOL_HEIGHT 30


@implementation ConnectionTool{
    CGPoint initialTouchLocationInView;
    CAShapeLayer *lineLayer; // shows the line connecting the SpaceToken and the actual location
    SpaceToken *counterPart;
    NSMutableArray <NSLayoutConstraint*> *constraintsArray;
    BOOL hasReportedDraggingEvent;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


#pragma mark --Initialization--

- (id) init{
    self = [super init];

    self.isLineLayerOn = NO;
    self.isDraggable = YES;
    
    // Initialize instant variables
    lineLayer = [CAShapeLayer layer];
    counterPart = nil;
    constraintsArray = [[NSMutableArray alloc] init];
    hasReportedDraggingEvent = false;
    
    [self registerButtonEvents];
    
    // Configure appearance
    self.frame = CGRectMake(0, 0, CONNECTION_TOOL_WIDTH, CONNECTION_TOOL_HEIGHT);
    [self setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.titleLabel setFont:[UIFont systemFontOfSize:12]];
    
    return self;
}

- (void)attachToSpaceToken:(SpaceToken *)spaceToken{
    
    // Connect the counterpart
    counterPart = spaceToken;
    
    float width = CONNECTION_TOOL_WIDTH;
    float height = CONNECTION_TOOL_HEIGHT;
    
    // Configure the appearance
    [self setTitle: spaceToken.spatialEntity.name forState:UIControlStateNormal];

    
    // Need to attach to the main map view, not the SpaceToken,
    // so Connection Tool can be touched when SpaceToken is touched
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    [mapView addSubview:self];
    
    // This is necessary to specify constraints programmatically
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Add the constraints
    [constraintsArray addObject:
     [NSLayoutConstraint constraintWithItem:self
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:spaceToken
                                  attribute:NSLayoutAttributeCenterX
                                 multiplier:1.0
                                   constant:0.0]];
    
    [constraintsArray addObject:
     [NSLayoutConstraint constraintWithItem:self
                                  attribute:NSLayoutAttributeCenterY
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:spaceToken
                                  attribute:NSLayoutAttributeCenterY
                                 multiplier:1.0
                                   constant:-spaceToken.frame.size.height/2 - 50]];
    
    [constraintsArray addObject:
     [NSLayoutConstraint constraintWithItem:self
                                  attribute:NSLayoutAttributeWidth
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:0
                                   constant:CONNECTION_TOOL_WIDTH]];

    [constraintsArray addObject:
     [NSLayoutConstraint constraintWithItem:self
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                 multiplier:0
                                   constant:CONNECTION_TOOL_HEIGHT]];
    
    [mapView addConstraints:constraintsArray];
//    [spaceToken addSubview:self];
}


// Why do I have this method? I want to have finer control of touches
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
    if (sender != self)
        return;
    
    NSLog(@"Touch down!");
    
    // There could be multiple touch events!
    // Need to find the touch even associated with self
    UITouch *touch = nil;
    for (UITouch *aTouch in [event allTouches]){
        if ([aTouch view] == self)
            touch = aTouch;
    }
    // Cache the initial button down location
    initialTouchLocationInView = [touch locationInView:self.superview];
}

- (void) buttonUp:(UIButton*)sender forEvent:(UIEvent*)event{
    
    // Do nothing if the event is not triggered by self
    if (sender != self)
        return;
    
    NSLog(@"Touch up!");

    // Remove self from the super view
    [self removeFromSuperview];
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
    
    if (self.isDraggable){
        
        // handle the dragging event if the button is draggable
        [self handleDragToScreenAction:touch];
    }
}

//---------------
// Handle dragToScreen action
//---------------
- (void)handleDragToScreenAction: (UITouch *) touch{
    
    // Instantiate another connection tool if the current one is being dragged out
    if (!hasReportedDraggingEvent){
        hasReportedDraggingEvent = YES;
        self.translatesAutoresizingMaskIntoConstraints = YES;
        
        // Create a new connection tool
        ConnectionTool *connectionTool = [[ConnectionTool alloc] init];
        [connectionTool attachToSpaceToken: counterPart];
        
        // Change the appearance
        [[self layer] addSublayer: lineLayer];
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
    
    // Check if the connection tool touches any of the SpaceTokens
    SpaceToken *resultToken = nil;
    
    // Get the TokenCollection object
    TokenCollection *tokenCollection = [TokenCollection sharedManager];
    
    // Get the touch coordinates in mapView
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    CGPoint touchPoint = [touch locationInView:mapView];
    CGPoint previoustouchPoint =
    [touch previousLocationInView:mapView];
    
    for (SpaceToken *aToken in tokenCollection.tokenArray){
        CGRect buttonFrame = aToken.frame;
        
        // Make sure the route creation tool is only triggered once
        if (CGRectContainsPoint(buttonFrame, touchPoint)
            &&
            !CGRectContainsPoint(buttonFrame, previoustouchPoint))
        {
            resultToken = aToken;
            NSLog(@"SpaceToken: %@ tapped.", aToken.spatialEntity.name);
            
            // Flash the touched SpaceToken
            [aToken flashToken];
            
            // Connection tool only supports the connection of POI
            
            if ([aToken.spatialEntity isKindOfClass:[POI class]] &&
                [counterPart.spatialEntity isKindOfClass:[POI class]])
            {
                // Create a route
                POI *sourcePOI = counterPart.spatialEntity;
                POI *destinationPOI = aToken.spatialEntity;
                [Route addRouteWithSource:sourcePOI Destination:destinationPOI];
            }
            
            break;
        }
    }
    
}

@end
