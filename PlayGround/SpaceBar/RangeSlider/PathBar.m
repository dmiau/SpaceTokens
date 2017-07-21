//
//  PathBar.m
//  PathBar
//
//  Created by Colin Eberhardt on 22/03/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "PathBar.h"
#import <QuartzCore/QuartzCore.h>
#import "PathBarTrackLayer.h"
#import "Elevator.h"

#define BOUND(VALUE, LOWER, UPPER)	MIN(MAX(VALUE, LOWER), UPPER)

@implementation PathBar
{
    PathBarTrackLayer* _trackLayer;
    Elevator* _elevator;
    
    float _useableTrackLength;
    CGPoint _previousTouchPoint;
    
    struct {
        unsigned int privateSliderOnePointTouched:1;
        unsigned int sliderTwoPOintsTouched:1;
        unsigned int privateSliderElevatorMoved:1;
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

GENERATE_SETTER(trackPaddingInPoints, float, setTrackPaddingInPoints, redrawLayers)

GENERATE_SETTER(maximumValue, float, setMaximumValue, setLayerFrames)

GENERATE_SETTER(minimumValue, float, setMinimumValue, setLayerFrames)

//GENERATE_SETTER(lowerValue, float, setLowerValue, setLayerFrames)
//
//GENERATE_SETTER(upperValue, float, setUpperValue, setLayerFrames)

- (void)setDelegate:(id <PathBarDelegate>)aDelegate {
    if (_delegate != aDelegate) {
        _delegate = aDelegate;
        
        delegateRespondsTo.privateSliderOnePointTouched = [_delegate
            respondsToSelector:@selector(privateSliderOnePointTouched:)];
        delegateRespondsTo.sliderTwoPOintsTouched = [_delegate
            respondsToSelector:@selector(privateSliderTwoPOintsTouchedLow:high:)];
        delegateRespondsTo.privateSliderElevatorMoved = [_delegate
                respondsToSelector:@selector(privateSliderElevatorMovedLow: high: fromLowToHigh:)];
    }
}


- (void) redrawLayers
{
    [_trackLayer setNeedsDisplay];
}




//--------------------------------
// Initializations
//--------------------------------
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _trackHighlightColour = [UIColor colorWithRed:0.0 green:0.45 blue:0.94 alpha:1.0];
        _trackColour = [UIColor colorWithWhite:0.6 alpha:0.5];
        _curvatiousness = 1.0;
        
        // Initialization code
        _minimumValue = 0.0;
        _maximumValue = 10.0;
        _trackPaddingInPoints = 60;
        
        _blankXBias = frame.size.width/2;
        
        _upperTouch = nil;
        _lowerTouch = nil;
        
        _pathBarMode = MAP;
        
        _trackTouchingSet = [[NSMutableSet alloc] init];
        
        // Initialize the track layer
        _trackLayer = [[PathBarTrackLayer alloc] init];
        _trackLayer.slider = self;
        _trackLayer.userInteractionEnabled = NO;
        _trackLayer.backgroundColor =[UIColor clearColor];
        [self addSubview:_trackLayer];
        
        // Initialize the elevator layer
        _elevator = [Elevator layer];
        _elevator.sliderContainer = self;
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
    //-----------------
    // Set up the track
    //-----------------
    CGRect trackFrame = self.bounds;
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


// the position is wrt to _trackLayer (with bound check)
- (float) valueForPosition:(float)position{
    
    // Convert from position (in _trackLayer) to value
    float tempValue =  position/_useableTrackLength *
    (_maximumValue - _minimumValue);
    
    // Check if the value is within the bound.
    return BOUND(tempValue, _minimumValue, _maximumValue);
}

//-----------------
// Interactions
//-----------------

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    // Exapand the width of the bar
//    CGRect originalFrame = self.superview.frame;
//    CGRect newFrame = CGRectMake(originalFrame.origin.x - originalFrame.size.width,
//                                 originalFrame.origin.y,
//                                 originalFrame.size.width*2,
//                                 originalFrame.size.height);
//    self.superview.frame = newFrame;
    
    // trackTouchingSet keeps tracking of all the touching events
    for (UITouch *aTouch in touches){
        
        if (![self isTouchValid:aTouch]){
            // If the touch is out of bound, do nothing
            NSMutableSet *aSet = [[NSMutableSet alloc] init];
            [aSet addObject:aTouch];
            [self touchesCancelled:aSet withEvent:nil];
            
        }else{
            if (![self.trackTouchingSet containsObject:aTouch])
            {
                [self.trackTouchingSet addObject:aTouch];
            }
        }
    }
    
    if ([self.trackTouchingSet count] == 1){
        // One point touched
        CGPoint touchPoint = [[_trackTouchingSet anyObject]
                              locationInView:_trackLayer];
        
        if (touchPoint.y > 0 && touchPoint.y < _trackLayer.frame.size.height){
            float aValue = [self valueForPosition: touchPoint.y];
            
            if (self.pathBarMode == MAP){
                
                //--------------------
                // Single touch in MAP mode
                //--------------------
                
                [_elevator touchElevatorPointA:aValue];
                // Update the elevator and the map
                [self updateElevatorThenMap];
            }else{

                //--------------------
                // Single touch in StreetView mode
                //--------------------
                [_elevator touchSingleDot:aValue];
                
                [_elevator setNeedsDisplay];
                
                if (delegateRespondsTo.sliderTwoPOintsTouched){
                    [self.delegate privateSliderOnePointTouched:
                     _elevator.lowerValue/_maximumValue];
                }                
            }
        }
    }else if ([self.trackTouchingSet count] == 2){
        // Two points touched
        float twoValues[2];
        
        // To detect _upperValue and _lowerValue
        int i = 0;
        for (UITouch *aTouch in self.trackTouchingSet){
            CGPoint touchPoint = [aTouch locationInView:_trackLayer];
            twoValues[i] = [self valueForPosition: touchPoint.y];
            i++;
        }
        [_elevator touchElevatorPointA:twoValues[0] pointB:twoValues[1]];
        // Update the elevator and the map
        [self updateElevatorThenMap];
    }
}

- (bool) isTouchValid: (UITouch*) touch{
    CGPoint touchPoint = [touch locationInView:_trackLayer];
    return (touchPoint.y > 0 && touchPoint.y < _trackLayer.frame.size.height);
}


- (void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    
    if ([touches count] == 1 && [self.trackTouchingSet count] == 1){
        //--------------
        // One point is moved and there is only *one* touch point.
        // It is possible that one touch point is stationary and one touch point is moved.
        // (If so the one stationary touch point + one moving touch point casse should be handled as two touch points.)
        //--------------
        UITouch* touch = [touches anyObject];
        CGPoint locationInView = [touch locationInView:_trackLayer];
        CGPoint previousLoationInView = [touch previousLocationInView:_trackLayer];
        
        
        if (locationInView.y < 0 || locationInView.y > _trackLayer.frame.size.height){
            // Touch is out of bound. Do nothing?
        }else{
            // In oneFingerMove mode, the elevator does not accept lowerValue, upperValue updates from map
            _elevator.isElevatorOneFingerMoved = YES;
            
            // Convert both from positions to values
            float currentValue = [self valueForPosition:locationInView.y];
            float previousValue = [self valueForPosition:previousLoationInView.y];
            
            if (currentValue >= _minimumValue && currentValue <= _maximumValue){

                [_elevator translateFromPreviousValue:previousValue toCurrentValue:currentValue];
                
                // Smooth translation--the scale should not change
                [_elevator setNeedsDisplay];
                
                if (delegateRespondsTo.privateSliderElevatorMoved){
                    
                    bool directionFlag = (currentValue > previousValue);
                    [self.delegate privateSliderElevatorMovedLow:
                     _elevator.lowerValue/_maximumValue
                    high:_elevator.upperValue/_maximumValue
                     fromLowToHigh:directionFlag];
                }
                
                
                // Original scale changing code
//                // The following is necessary to maintain the size of the elevator
//                [self updateElevatorThenMap];
                // The following is necessary to maintain the size of the elevator
//                [_elevator  restoreElevatorParamsFromTouchPoint: currentValue];
//                [_elevator setNeedsDisplay];
            }
        }

    }else if ([self.trackTouchingSet count] == 2){
        //--------------
        // Two points are touched
        //--------------
        
        // Two points touched
        
        float twoValues[2];
        
        // To detect _upperValue and _lowerValue
        int i = 0;
        for (UITouch *aTouch in self.trackTouchingSet){
            CGPoint touchPoint = [aTouch locationInView:_trackLayer];
            twoValues[i] = [self valueForPosition: touchPoint.y];
            i++;
        }
        [_elevator touchElevatorPointA:twoValues[0] pointB:twoValues[1]];
        
        // Update the elevator and the map
        [self updateElevatorThenMap];
        
//        [CATransaction begin];
//        [CATransaction setDisableActions:YES] ;
//        
//        [self setLayerFrames];
//        
//        [CATransaction commit];
    }

    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    for (UITouch *aTouch in touches){
        [self.trackTouchingSet removeObject:aTouch];
    }
    
    // The following is called upon transitioning from two-finger touch to one finger touch
    // Need to fix the offset here
    if ([self.trackTouchingSet count] == 1){
        UITouch *aTouch = [self.trackTouchingSet anyObject];
        CGPoint touchPoint = [aTouch locationInView:_trackLayer];
        
        float aValue = [self valueForPosition: touchPoint.y];
        [_elevator touchElevatorPointA:aValue];
    }
    
    
    _elevator.isElevatorOneFingerMoved = NO;
}


// 1. Update the elevator visualization
// 2. Update the map
- (void) updateElevatorThenMap{
    [_elevator setNeedsDisplay];
    
    if (delegateRespondsTo.sliderTwoPOintsTouched){
        [self.delegate privateSliderTwoPOintsTouchedLow:
         _elevator.lowerValue/_maximumValue
        high:_elevator.upperValue/_maximumValue];
    }
}

- (void) updateElevatorPercentageLow:(double)low high:(double)high{
    // In oneFingerMove mode, the elevator does not accept lowerValue, upperValue updates from map
    if (!_elevator.isElevatorOneFingerMoved){
        
        if (isnan(low) || isnan(high)){
            _elevator.lowerValue = nan("");
            _elevator.upperValue = nan("");
        }else{
            _elevator.lowerValue = low * _maximumValue;
            _elevator.upperValue = high * _maximumValue;
        }
        
        [_elevator setNeedsDisplay];
    }
}

@end
