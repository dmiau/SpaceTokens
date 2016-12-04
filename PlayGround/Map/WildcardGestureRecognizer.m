//
//  CustomGestureRecognizer.m
//  SpaceBar
//
//  Created by dmiau on 7/6/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "WildcardGestureRecognizer.h"
#import "SpaceBar.h"

//http://stackoverflow.com/questions/1049889/how-to-intercept-touches-events-on-a-mkmapview-or-uiwebview-objects

@implementation WildcardGestureRecognizer
//@synthesize touchesBeganCallback;

-(id) init{
    if (self = [super init])
    {
        self.cancelsTouchesInView = NO;
    }
    return self;
}

//-----------------
// handle touches
//-----------------

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_touchesBeganCallback)
        _touchesBeganCallback(touches, event);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_touchesMovedCallback)
        _touchesMovedCallback(touches, event);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_touchesEndedCallback)
        _touchesEndedCallback(touches, event);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_touchesCancelledCallback)
        _touchesCancelledCallback(touches, event);
}


- (void)reset
{
}

- (void)ignoreTouch:(UITouch *)touch forEvent:(UIEvent *)event
{
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
//    if ([preventingGestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]){
//        return YES;
//    }else{
        return NO;
//    }
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
//    if ([preventedGestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]]){
//        return YES;
//    }else{
        return NO;
//    }
}


@end
