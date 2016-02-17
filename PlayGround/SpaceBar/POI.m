//
//  POI.m
//  SpaceBar
//
//  Created by Daniel on 2/1/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "POI.h"
#import "Constants.h"
#import "UIButton+Extensions.h"

@implementation POI

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


//----------------
// initialization
//----------------
- (id) init{
    self = [super init];
    if (self){
        _latLon = CLLocationCoordinate2DMake(0, 0);
        [self resetButton];
        [self registerButtonEvents];
    }
    return self;
}

- (void) registerButtonEvents{
    [self addTarget:self
             action:@selector(buttonDown:)
   forControlEvents:UIControlEventTouchDown];

//    [self addTarget:self
//             action:@selector(buttonDown:)
//   forControlEvents:UIControlEventTouchDragEnter];
    
    
    [self addTarget:self
               action:@selector(buttonUp:)
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
    
}

//-----------
// reattach to a superview
//-----------
- (void) resetButton{
    self.hasReportedDraggingEvent = [NSNumber numberWithBool:NO];
    
    [self setTitle:@"SpaceMark" forState:UIControlStateNormal];
    self.frame = CGRectMake(0, 20.0, 60.0, 20.0);
    [self setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    [self setBackgroundColor:[UIColor grayColor]];
    [self setTitleColor: [UIColor whiteColor]
               forState: UIControlStateNormal];
}

//-----------
// button methods
//-----------
- (void) buttonDown:(UIButton*) sender {
    
    // Do nothing if the event is not triggered by self
    if (sender != self)
        return;
    
    NSLog(@"Touch down!");
    self.hasReportedDraggingEvent = [NSNumber numberWithBool:NO];
    
    [self setBackgroundColor:[UIColor redColor]];
    
    NSNotification *notification = [NSNotification notificationWithName:AddToTouchingSetNotification
        object:self userInfo:nil];
    [[ NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void) buttonUp:(UIButton*)sender {
    
    // Do nothing if the event is not triggered by self
    if (sender != self)
        return;
    
    NSLog(@"Touch up!");
    [self setBackgroundColor:[UIColor grayColor]];
    NSNotification *notification = [NSNotification notificationWithName:RemoveFromTouchingSetNotification
        object:self userInfo:nil];
    [[ NSNotificationCenter defaultCenter] postNotification:notification];
    
    if ([self.hasReportedDraggingEvent boolValue]){
        self.hasReportedDraggingEvent = [NSNumber numberWithBool:NO];
        [self removeFromSuperview];
    }
}

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
    CGPoint previousLoationInView = [touch previousLocationInView:self.superview];
    CGPoint locationInButton = [touch locationInView:self];
    
    // Threshold the x position to distiguish wheather the button is dragged or clicked
    if ((self.superview.frame.size.width - locationInView.x) < 0.2 * self.superview.frame.size.width)
    {
        // Do nothing if the SpaceMark is not dragged far out enough
        return;
    }else{

        if (![self.hasReportedDraggingEvent boolValue]){
            // This is to make sure AddToDraggingSet notification is only sent once.
            self.hasReportedDraggingEvent = [NSNumber numberWithBool:YES];
            NSNotification *notification = [NSNotification notificationWithName:AddToDraggingSetNotification
                                                                         object:self userInfo:nil];
            [[ NSNotificationCenter defaultCenter] postNotification:notification];
            
            // Change the style of the dragging tocken
            self.titleLabel.font = [UIFont systemFontOfSize:20];
            [self setBackgroundColor:[UIColor clearColor]];
            [self setTitleColor: [UIColor redColor]
                       forState: UIControlStateNormal];
        }
        self.center = CGPointMake
        (self.center.x + locationInView.x - previousLoationInView.x,
         self.center.y + locationInView.y - previousLoationInView.y);
    }
}

@end
