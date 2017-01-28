//
//  ConnectionTool.m
//  SpaceBar
//
//  Created by dmiau on 11/18/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "ConnectionTool.h"
#import "SpaceToken.h"
#import "SpaceBar.h"
#import "TokenCollection.h"
#import "POI.h"
#import "Route.h"

#import "CustomMKMapView.h"


#define CONNECTION_TOOL_WIDTH 60
#define CONNECTION_TOOL_HEIGHT 40
#define CONNECTION_TOOL_OFFSET 50

@interface ConnectionTool ()

// buttonDragging is implemented in the Dragging category
- (void) buttonDragging:(UIButton *)sender forEvent: (UIEvent *)event;

@end


@implementation ConnectionTool


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
    [self.titleLabel setFont:[UIFont systemFontOfSize:14]];
    self.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:0.5];
    
    return self;
}

- (void)attachToSpaceToken:(SpaceToken *)spaceToken{
    
    // Connect the counterpart
    counterPart = spaceToken;
    spaceToken.connectionTool = self; // dependency injection
    
    float width = CONNECTION_TOOL_WIDTH;
    float height = CONNECTION_TOOL_HEIGHT;
    
    // Configure the appearance
    [self setTitle: spaceToken.spatialEntity.name forState:UIControlStateNormal];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    if ([spaceToken.spatialEntity.name length] > 8){
        self.titleLabel.numberOfLines = 2;
    }
        
    // Need to attach to tokenCollectionView, not the SpaceToken,
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
                                   constant:-spaceToken.frame.size.height/2 - CONNECTION_TOOL_OFFSET]];
    
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

    // Remove self from the super view
    [self removeFromSuperview];
}



@end
