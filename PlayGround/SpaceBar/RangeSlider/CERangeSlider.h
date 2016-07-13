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
- (void) sliderOnePointTouched;
- (void) sliderTwoPOintsTouched;
@end


@interface CERangeSlider : UIControl

@property (nonatomic, weak) id <CERangeSliderDelegate> delegate;

@property (nonatomic) float maximumValue;

@property (nonatomic) float minimumValue;

@property (nonatomic) float upperValue;

@property (nonatomic) float lowerValue;

@property (weak) UITouch *upperTouch;

@property (weak) UITouch *lowerTouch;

@property NSMutableSet *trackTouchingSet;

// stores a list of dots to be displayed on the track
@property NSMutableArray *trackDotsArray;

@property float blankXBias; 

@property (nonatomic) float curvatiousness;

@property (nonatomic) UIColor* trackColour;

@property (nonatomic) UIColor* trackHighlightColour;

@property (nonatomic) UIColor* knobColour;

- (float) positionForValue:(float)value;

@end
