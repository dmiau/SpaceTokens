//
//  CERangeSlider.m
//  CERangeSlider
//
//  Created by Colin Eberhardt on 22/03/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "CERangeSlider.h"
#import <QuartzCore/QuartzCore.h>
//#import "CERangeSliderKnobLayer.h"
#import "CERangeSliderTrackLayer.h"
#import "Elevator.h"

#define BOUND(VALUE, LOWER, UPPER)	MIN(MAX(VALUE, LOWER), UPPER)

@implementation CERangeSlider
{
    CERangeSliderTrackLayer* _trackLayer;
    Elevator* _elevator;
//    CERangeSliderKnobLayer* _upperKnobLayer;
//    CERangeSliderKnobLayer* _lowerKnobLayer;
    
    float _useableTrackLength;
    float _paddingLength;
    CGPoint _previousTouchPoint;
    
    struct {
        unsigned int sliderOnePointTouched:1;
        unsigned int sliderTwoPOintsTouched:1;
    } delegateRespondsTo;
}

#define GENERATE_SETTER(PROPERTY, TYPE, SETTER, UPDATER) \
@synthesize PROPERTY = _##PROPERTY; \
\
- (void)SETTER:(TYPE)PROPERTY { \
    if (_##PROPERTY != PROPERTY) { \
        _##PROPERTY = PROPERTY; \
        [self UPDATER]; \
    } \
}

GENERATE_SETTER(trackHighlightColour, UIColor*, setTrackHighlightColour, redrawLayers)

GENERATE_SETTER(trackColour, UIColor*, setTrackColour, redrawLayers)

GENERATE_SETTER(curvatiousness, float, setCurvatiousness, redrawLayers)

GENERATE_SETTER(knobColour, UIColor*, setKnobColour, redrawLayers)

GENERATE_SETTER(maximumValue, float, setMaximumValue, setLayerFrames)

GENERATE_SETTER(minimumValue, float, setMinimumValue, setLayerFrames)

//GENERATE_SETTER(lowerValue, float, setLowerValue, setLayerFrames)
//
//GENERATE_SETTER(upperValue, float, setUpperValue, setLayerFrames)

- (void)setDelegate:(id <CERangeSliderDelegate>)aDelegate {
    if (_delegate != aDelegate) {
        _delegate = aDelegate;
        
        delegateRespondsTo.sliderOnePointTouched = [_delegate
            respondsToSelector:@selector(sliderOnePointTouched:)];
        delegateRespondsTo.sliderTwoPOintsTouched = [_delegate
            respondsToSelector:@selector(sliderTwoPOintsTouchedLow:high:)];
    }
}


- (void) redrawLayers
{
//    [_upperKnobLayer setNeedsDisplay];
//    [_lowerKnobLayer setNeedsDisplay];
    [_trackLayer setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _trackHighlightColour = [UIColor colorWithRed:0.0 green:0.45 blue:0.94 alpha:1.0];
        _trackColour = [UIColor colorWithWhite:0.9 alpha:0.5];
        _knobColour = [UIColor whiteColor];
        _curvatiousness = 1.0;
        
        // Initialization code
        _minimumValue = 0.0;
        _maximumValue = 10.0;
        _trackPaddingInPoints = 30;
        
        _blankXBias = 30;
        
        _upperTouch = nil;
        _lowerTouch = nil;
        
        _trackTouchingSet = [[NSMutableSet alloc] init];
        
        // Initialize the track layer
        _trackLayer = [[CERangeSliderTrackLayer alloc] init];
        _trackLayer.slider = self;
        _trackLayer.userInteractionEnabled = NO;
        _trackLayer.backgroundColor =[UIColor clearColor];
        [self addSubview:_trackLayer];
        
        // Initialize the elevator layer
        _elevator = [Elevator layer];
        _elevator.slider = self;
        [_trackLayer.layer addSublayer:_elevator];
        
        [self setLayerFrames];
        
        // Enable multitouch control
        self.multipleTouchEnabled = YES;
    }
    return self;
}


// This specify the parameters of the track and the elevator
- (void) setLayerFrames
{
    // create a larger drawing area
//    _trackLayer.frame = CGRectInset(self.bounds, 0, 0);
//    // self.bounds.size.width / 3.5
    
    //-----------------
    // Set up the track
    //-----------------
    CGRect trackFrame = self.bounds;
    trackFrame.origin.x = -_blankXBias;
    trackFrame.size.width += _blankXBias;
    
    // Add cell padding for the trackLayer?
    trackFrame.origin.y = _trackPaddingInPoints;
    trackFrame.size.height -= _trackPaddingInPoints *2;
    
    _trackLayer.frame = trackFrame;
    [_trackLayer setNeedsDisplay];

    //-----------------
    // Set up the elevator
    //-----------------
    CGRect elevatorFrame = CGRectMake(0, 0,
                                      trackFrame.size.width, trackFrame.size.height);
    _elevator.frame = elevatorFrame;
    [_elevator setNeedsDisplay];
    
    _useableTrackLength = self.bounds.size.height - _trackPaddingInPoints *2;
}


// the position is wrt to _trackLayer
- (float) valueForPosition:(float)position{
    return position/_useableTrackLength *
    (_maximumValue - _minimumValue);
}

//-----------------
// Interactions
//-----------------

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan is called!");
    
    NSLog(@"# of touches in event: %lu", [[event allTouches] count]);
    
    for (UITouch *aTouch in touches){
        if (![self.trackTouchingSet containsObject:aTouch])
        {
            [self.trackTouchingSet addObject:aTouch];
        }
    }
    
    // Check if the elevator is touched
    if ([self.trackTouchingSet count] == 1){
        CGPoint touchPoint = [[_trackTouchingSet anyObject]
                              locationInView:_trackLayer];
        float aValue = [self valueForPosition: touchPoint.y];
        
        if ([_elevator hitTestOfValue:aValue]){
            // The elevator is touched
            _elevator.isTouched = true;
            [_elevator specifyElevatorParamsWithTouchValue:aValue];
        }else{
            _elevator.isTouched = false;
            [self updateLowerUpperValues];
            [self setLayerFrames];
        }
    }
}


- (void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if (_elevator.isTouched && [touches count] == 1){
        UITouch* touch = [touches anyObject];
        CGPoint locationInView = [touch locationInView:self];
        CGPoint previousLoationInView = [touch previousLocationInView:self];
        
        // This is necessary to make sure the values are within the bound.
        float currentY = BOUND(locationInView.y - _trackPaddingInPoints,
                               0, _useableTrackLength);
        float previousY = BOUND(previousLoationInView.y - _trackPaddingInPoints,
                                0, _useableTrackLength);
        float diff = currentY - previousY;
        
        [_elevator translateByPoints: diff];

        // The following is necessary to maintain the size of the elevator
        if (delegateRespondsTo.sliderTwoPOintsTouched){
            
            [self.delegate sliderTwoPOintsTouchedLow: _elevator.lowerValue/_maximumValue
                                                high:_elevator.upperValue/_maximumValue];
            [_elevator loadElevatorParamsFromTouchPoint:
             currentY / _useableTrackLength * (_maximumValue - _minimumValue)];
            
            // Without this call the size of the elevator shrinks over time!
            [self.delegate sliderTwoPOintsTouchedLow: _elevator.lowerValue/_maximumValue
                                                high:_elevator.upperValue/_maximumValue];
        }
        
    }else{
        [self updateLowerUpperValues];
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES] ;
        
        [self setLayerFrames];
        
        [CATransaction commit];
    }

    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    _elevator.isTouched = false;
    
    for (UITouch *aTouch in touches){
        [self.trackTouchingSet removeObject:aTouch];
    }
    
    // Leave the elevator intact?
//    [self updateLowerUpperValues];
    [self setLayerFrames];
}

- (void) updateLowerUpperValues{
    
    if ([_trackTouchingSet count] == 0){

        // I don't see any reason to disable the elevator indicator
//        _lowerValue = -1;
//        _upperValue = -1;
    }else if ([_trackTouchingSet count] == 1){
        //--------------
        // One touch is detected
        //--------------
        
        CGPoint touchPoint = [[_trackTouchingSet anyObject]
                              locationInView:_trackLayer];
                
        float aValue = BOUND([self valueForPosition: touchPoint.y]
                             , _minimumValue, _maximumValue);
        
        _elevator.lowerValue = aValue;
        _elevator.upperValue = -1;

        if (delegateRespondsTo.sliderOnePointTouched)
        {
            [self.delegate sliderOnePointTouched: aValue/_maximumValue];
        }        
        
    }else if ([_trackTouchingSet count] == 2){
        
        //--------------
        // Two touches are detected
        //--------------
        float twoValues[2];
        
        // To detect _upperValue and _lowerValue
        int i = 0;
        for (UITouch *aTouch in self.trackTouchingSet){
            CGPoint touchPoint = [aTouch locationInView:_trackLayer];
            
            twoValues[i] = BOUND([self valueForPosition: touchPoint.y],
                                 _minimumValue, _maximumValue);
            i++;
        }
        _elevator.lowerValue = MIN(twoValues[0], twoValues[1]);
        _elevator.upperValue = MAX(twoValues[0], twoValues[1]);
        
        if (delegateRespondsTo.sliderTwoPOintsTouched){
            [self.delegate sliderTwoPOintsTouchedLow: _elevator.lowerValue/_maximumValue
                                                high:_elevator.upperValue/_maximumValue];
        }
    }
    
    [_elevator setNeedsDisplay];
}

- (void) updateElevatorPercentageLow:(double)low high:(double)high{
    _elevator.lowerValue = low * _maximumValue;
    _elevator.upperValue = high * _maximumValue;
    [_elevator setNeedsDisplay];
}

@end
