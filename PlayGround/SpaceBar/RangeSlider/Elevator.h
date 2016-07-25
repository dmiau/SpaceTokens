//
//  Elevator.h
//  SpaceBar
//
//  Created by Daniel on 7/13/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@class CERangeSlider;

@interface Elevator : CALayer

@property CERangeSlider* slider;

@property (nonatomic) float upperValue;

@property (nonatomic) float lowerValue;



- (void)translateFromPreviousValue: (float) previousValue toCurrentValue: (float) currentValue;

- (void)restoreElevatorParamsFromTouchPoint: (float) touchPoint;

//@property bool isTouched;
//- (bool)hitTestOfValue: (float) value;
//- (void)specifyElevatorParamsWithTouchValue: (float) value;


- (void) touchPointA: (float)value;
- (void) touchPointA: (float)valueA pointB: (float) valueB;
@end
