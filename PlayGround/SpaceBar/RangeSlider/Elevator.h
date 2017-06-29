//
//  Elevator.h
//  NavTools
//
//  Created by Daniel on 7/13/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@class CERangeSlider;

@interface Elevator : CALayer

@property CERangeSlider* sliderContainer;

@property (nonatomic) float upperValue;

@property (nonatomic) float lowerValue;

@property bool isElevatorOneFingerMoved;

// Support the traslation of the elevator
- (void)translateFromPreviousValue: (float) previousValue toCurrentValue: (float) currentValue;

- (void)restoreElevatorParamsFromTouchPoint: (float) touchPoint;


- (void) touchSingleDot: (float) value;
- (void) touchElevatorPointA: (float)value;
- (void) touchElevatorPointA: (float)valueA pointB: (float) valueB;
@end
