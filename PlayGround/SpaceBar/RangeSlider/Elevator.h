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

@property bool isTouched;
- (void)specifyElevatorParamsWithTouchValue: (float) value;
- (void)loadElevatorParamsFromTouchPoint: (float) touchPoint;
- (bool)hitTestOfValue: (float) value;
- (void)translateByPoints: (float) points;
@end
