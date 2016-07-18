//
//  CERangeSlider.h
//  CERangeSlider
//
//  Created by Colin Eberhardt on 22/03/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CERangeSliderDelegate <NSObject>
@optional
- (void) sliderOnePointTouched:(double)percentage;
- (void) sliderTwoPOintsTouchedLow:(double) percentageLow high:(double)percentageHigh;
@end


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
//
@property float trackPaddingInPoints;

- (void) updateElevatorPercentageLow: (double)low high:(double)high;
@end
