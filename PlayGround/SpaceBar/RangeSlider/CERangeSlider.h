//
//  CERangeSlider.h
//  CERangeSlider
//
//  Created by Colin Eberhardt on 22/03/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>

//-----------------
// Delegate
//-----------------
@protocol CERangeSliderDelegate <NSObject>
@optional
- (void) sliderOnePointTouched:(double)percentage;
- (void) sliderTwoPOintsTouchedLow:(double) percentageLow high:(double)percentageHigh;
@end

typedef enum {MAP, STREETVIEW} PathBarMode;
// MAP mode: the elevator width varies for single taps; STREETVIEW mode: the elevator width fixes for single taps

//-----------------
// Class definition
//-----------------
@interface CERangeSlider : UIControl

@property (nonatomic, weak) id <CERangeSliderDelegate> delegate;

@property (nonatomic) float maximumValue;

@property (nonatomic) float minimumValue;

@property (weak) UITouch *upperTouch;

@property (weak) UITouch *lowerTouch;

@property NSMutableSet *trackTouchingSet;

@property float blankXBias; 

@property (nonatomic) float curvatiousness;

@property (nonatomic) UIColor* trackColour;

@property (nonatomic) UIColor* trackHighlightColour;

@property (nonatomic) UIColor* knobColour;

// Style Control
@property float trackPaddingInPoints;

@property PathBarMode pathBarMode;

// Interface for outside to update the elevator
- (void) updateElevatorPercentageLow: (double)low high:(double)high;
@end
