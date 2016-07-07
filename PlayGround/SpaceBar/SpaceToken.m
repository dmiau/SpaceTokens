//
//  SpaceMark.m
//  SpaceBar
//
//  Created by Daniel on 2/1/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SpaceToken.h"
#import "UIButton+Extensions.h"
#import "Constants.h"

@implementation SpaceToken

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id) init{
    self = [super init];
    
    if (self){

        self.circleLayer = [CAShapeLayer layer];
        self.lineLayer = [CAShapeLayer layer];
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
    self.counterPart = nil;
    [self configureAppearanceForType:DOCKED];
}


//-----------
// configure the appearance
//-----------
- (void) configureAppearanceForType:(spaceTokenType)type{
    switch (type) {
        case DOCKED:
            [self addSubview:self.titleLabel];
            [self setTitle:@"SpaceToken" forState:UIControlStateNormal];
            self.frame = CGRectMake(0, 20.0, 60.0, 20.0);
            [self setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
            self.titleLabel.font = [UIFont systemFontOfSize:12];
            [self setBackgroundColor:[UIColor grayColor]];
            [self setTitleColor: [UIColor whiteColor]
                       forState: UIControlStateNormal];
            [self.circleLayer removeFromSuperlayer];
            [self.lineLayer removeFromSuperlayer];
            break;
        case DRAGGING:
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
            [[self layer] addSublayer:self.lineLayer];
            break;
        default:
            break;
    }
    
    
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
    [self.lineLayer removeFromSuperlayer];
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
    if ((self.superview.frame.size.width - locationInView.x) < self.frame.size.width*1.2)
    {
        // Do nothing if the SpaceMark is not dragged far out enough
        return;
    }else{
        
        if (![self.hasReportedDraggingEvent boolValue]){
            // This is to make sure AddToDraggingSet notification is only sent once.
            self.hasReportedDraggingEvent = [NSNumber numberWithBool:YES];
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
}



@end
