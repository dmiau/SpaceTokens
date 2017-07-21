//
//  PathBar.h
//  PathBar
//
//  Created by Colin Eberhardt on 22/03/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>

//-----------------
// Delegate
//-----------------
@protocol PathBarDelegate <NSObject>
- (void) privateSliderOnePointTouched:(double)percentage;
- (void) privateSliderTwoPOintsTouchedLow:(double) percentageLow high:(double)percentageHigh;
- (void) privateSliderElevatorMovedLow:(double) percentageLow high:(double)percentageHigh
                                                        fromLowToHigh: (bool)directionFlag;
@end

typedef enum {MAP, STREETVIEW} PathBarMode;
// MAP mode: the elevator width varies for single taps; STREETVIEW mode: the elevator width fixes for single taps

//-----------------
// Class definition
//-----------------
@interface PathBar : UIControl

@property (nonatomic, weak) id <PathBarDelegate> delegate;

@property (nonatomic) float maximumValue;

@property (nonatomic) float minimumValue;

@property (weak) UITouch *upperTouch;

@property (weak) UITouch *lowerTouch;

@property NSMutableSet *trackTouchingSet;

@property float blankXBias; 

@property (nonatomic) float curvatiousness;

@property (nonatomic) UIColor* trackColour;

@property (nonatomic) UIColor* trackHighlightColour;

// Style Control
@property float trackPaddingInPoints;

@property PathBarMode pathBarMode;

- (void) setLayerFrames;

// Interface for outside to update the elevator
- (void) updateElevatorPercentageLow: (double)low high:(double)high;
@end
