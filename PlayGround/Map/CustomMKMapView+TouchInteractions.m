//
//  CustomMKMapView+TouchInteractions.m
//  SpaceBar
//
//  Created by Daniel on 11/28/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "CustomMKMapView+TouchInteractions.h"
#import "WildcardGestureRecognizer.h"

@implementation CustomMKMapView (TouchInteractions)

- (void)p_initGestureRecognizer{

    //-----------------
    // Initialize a gesture layer
    //-----------------
    UIView *gestureView = [[UIView alloc] init];
    [gestureView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:gestureView];
    
    gestureView.translatesAutoresizingMaskIntoConstraints = NO;
    
    //-----------------
    // Add constraints of the gesture layer
    //-----------------
    NSMutableDictionary *viewDictionary = [[NSMutableDictionary alloc] init];
    viewDictionary[@"realMap"] = self;
    viewDictionary[@"gestureView"] = gestureView;
    
    NSMutableArray *constraintStringArray = [[NSMutableArray alloc] init];
    
    // Add constraints for the gesture view
    [constraintStringArray addObject:@"H:[gestureView(==realMap)]"];
    [constraintStringArray addObject:@"V:[gestureView(==realMap)]"];
    [constraintStringArray addObject:@"V:|-0-[gestureView]-0-|"];
    [constraintStringArray addObject:@"H:|-0-[gestureView]-0-|"];
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    for (NSString *constraintString in constraintStringArray){
        [constraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:constraintString
                                                 options:0 metrics:nil
                                                   views:viewDictionary]];
    }
    
    [self addConstraints:constraints];
    
    //-----------------
    // Initialize custom gesture recognizer
    //-----------------
    
    // Q: Why do I need to use a custom gesture recognizer?
    // A1: Because I need to disable the default rotation gesture recognizer
    // A2: I don't want my touch to be cancelled by other gesture recognizer
    // (http://stackoverflow.com/questions/5818692/how-to-avoid-touches-cancelled-event)
    
    WildcardGestureRecognizer * tapInterceptor = [[WildcardGestureRecognizer alloc] init];
    
    tapInterceptor.touchesBeganCallback = ^(NSSet<UITouch*>* touches, UIEvent * event) {
        [self customTouchesBegan:touches withEvent:event];
    };
    
    tapInterceptor.touchesEndedCallback = ^(NSSet<UITouch*>* touches, UIEvent * event) {
        [self customTouchesEnded:touches withEvent:event];
    };
    
    tapInterceptor.touchesMovedCallback = ^(NSSet<UITouch*>* touches, UIEvent * event) {
        [self customTouchesMoved:touches withEvent:event];
    };
    
    tapInterceptor.touchesCancelledCallback = ^(NSSet<UITouch*>* touches, UIEvent * event) {
        [self customTouchesCancelled:touches withEvent:event];
    };
    
    tapInterceptor.delegate = self;
    
    //--------------------------
    // Add gesture recognizers
    //--------------------------
    [gestureView setHidden:YES];
    [self addGestureRecognizer:tapInterceptor];

//     //Let the gesture layer to handle the gesture
//     [gestureView addGestureRecognizer:tapInterceptor];
}

#pragma mark --gesture recognizer--
//-----------------------------
// Touch related methods
//-----------------------------
// this makes sure all UIControls are still functional
// http://stackoverflow.com/questions/5222998/uigesturerecognizer-blocks-subview-for-handling-touch-events?rq=1
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch{
    
    if ([[touch view] isKindOfClass:[UIControl class]]){
        return false;
    }else{
        return true;
    }
}

//---------------------------
// Touch began
//---------------------------
-(void)customTouchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
        
    if (_delegateRespondsTo.mapTouchBegin)
    {
        [self.delegate mapTouchBegan: touches withEvent:event];
    }    
    
    if (self.isDebugModeOn){
        
        //----------------
        // investigate the region corresponding to the cgrect
        //----------------
        //        CGRect realRect = [self convertRegion:self.region toRectToView:self];
        //        CGRect hiddenRect = [hiddenMap convertRegion:hiddenMap.region toRectToView:hiddenMap];
        
        //        NSLog(@"Real rect: %@", NSStringFromCGRect(realRect));
        //        NSLog(@"Hidden rect: %@", NSStringFromCGRect(hiddenRect));
        
        //----------------
        // Print out debug info
        //----------------
        MKMapRect mapRect = self.visibleMapRect;
        NSLog(@"MapRect Origin: (%g, %g), Size: (%g, %g)",
              mapRect.origin.x, mapRect.origin.y,
              mapRect.size.width, mapRect.size.height);
        
        //-------------------------
        NSLog(@"real: centroid:(%g, %g), span:(%g, %g)", self.region.center.latitude,
              self.region.center.longitude, self.region.span.latitudeDelta, self.region.span.longitudeDelta);
        //        NSLog(@"hiddenMap: centroid:(%g, %g), span:(%g, %g)", hiddenMap.region.center.latitude,
        //              hiddenMap.region.center.longitude, hiddenMap.region.span.latitudeDelta, hiddenMap.region.span.longitudeDelta);
    }
}

//---------------------------
// Touch moved
//---------------------------
-(void)customTouchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if (_delegateRespondsTo.mapTouchMoved)
    {
        [self.delegate mapTouchMoved: touches withEvent:event];
    }
}

//---------------------------
// Touch ended
//---------------------------
-(void)customTouchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if (_delegateRespondsTo.mapTouchEnded){
        [self.delegate mapTouchEnded: touches withEvent:(UIEvent *)event];
    }
//    NSLog(@"touch ended");
}

-(void)customTouchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_delegateRespondsTo.mapTouchEnded){
        [self.delegate mapTouchEnded: touches withEvent:(UIEvent *)event];
    }
//    NSLog(@"touch canceled");
}



//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    BOOL foundFlag = false;
//    
//    if ([otherGestureRecognizer isKindOfClass: [UIPinchGestureRecognizer class]]
//        )
//    {
//        [defaultGestureRecognizers addObject:otherGestureRecognizer];
//        NSLog(@"Found pinch recognizer!");
//        foundFlag = true;
//    }
//    
//    if ([otherGestureRecognizer isKindOfClass: [UIRotationGestureRecognizer class]]
//        )
//    {
//        [defaultGestureRecognizers addObject:otherGestureRecognizer];
//
//        NSLog(@"Found rotation recognizer!");
//        foundFlag = true;
//    }
//    
//    if (self.isSpaceTokenEnabled){
//        
//        for (UIGestureRecognizer *aRecognizer in defaultGestureRecognizers){
//            [aRecognizer setEnabled:NO];
//        }
//        return !foundFlag;
//        
//    }else{
//        for (UIGestureRecognizer *aRecognizer in defaultGestureRecognizers){
//            [aRecognizer setEnabled:YES];
//        }
//        return YES;
//    }
//}

@end
