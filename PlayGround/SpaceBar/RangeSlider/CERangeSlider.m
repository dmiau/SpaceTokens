//
//  CERangeSlider.m
//  CERangeSlider
//
//  Created by Colin Eberhardt on 22/03/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "CERangeSlider.h"
#import <QuartzCore/QuartzCore.h>
#import "CERangeSliderKnobLayer.h"
#import "CERangeSliderTrackLayer.h"

@implementation CERangeSlider
{
    CERangeSliderTrackLayer* _trackLayer;
    CERangeSliderKnobLayer* _upperKnobLayer;
    CERangeSliderKnobLayer* _lowerKnobLayer;
    
    float _knobWidth;
    float _useableTrackLength;
    
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

GENERATE_SETTER(lowerValue, float, setLowerValue, setLayerFrames)

GENERATE_SETTER(upperValue, float, setUpperValue, setLayerFrames)

- (void)setDelegate:(id <CERangeSliderDelegate>)aDelegate {
    if (_delegate != aDelegate) {
        _delegate = aDelegate;
        
        delegateRespondsTo.sliderOnePointTouched = [_delegate
            respondsToSelector:@selector(sliderOnePointTouched)];
        delegateRespondsTo.sliderTwoPOintsTouched = [_delegate
            respondsToSelector:@selector(sliderTwoPOintsTouched)];
    }
}


- (void) redrawLayers
{
    [_upperKnobLayer setNeedsDisplay];
    [_lowerKnobLayer setNeedsDisplay];
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
        
        _smallValueOnTopOfBar = true;
        
        // Initialization code
        _minimumValue = 0.0;
        _maximumValue = 10.0;
        
        _upperValue = -1.0;
        _lowerValue = -1.0;
        
        _blankXBias = 30;
        
        _upperTouch = nil;
        _lowerTouch = nil;
        
        _trackTouchingSet = [[NSMutableSet alloc] init];
        _trackDotsArray = [[NSMutableArray alloc] init];
        
        _trackLayer = [CERangeSliderTrackLayer layer];
        _trackLayer.slider = self;
        [self.layer addSublayer:_trackLayer];

//        _upperKnobLayer = [CERangeSliderKnobLayer layer];
//        _upperKnobLayer.slider = self;
//        [_upperKnobLayer setHidden:YES];
//        [self.layer addSublayer:_upperKnobLayer];
//
//        _lowerKnobLayer = [CERangeSliderKnobLayer layer];
//        _lowerKnobLayer.slider = self;
//        [_lowerKnobLayer setHidden:YES];
//        [self.layer addSublayer:_lowerKnobLayer];
        
        [self setLayerFrames];
        
        // Enable multitouch control
        self.multipleTouchEnabled = YES;
    }
    return self;
}
                                           
- (void) setLayerFrames
{
    // create a larger drawing area
//    _trackLayer.frame = CGRectInset(self.bounds, 0, 0);
//    // self.bounds.size.width / 3.5
    
    CGRect trackFrame = self.bounds;
    trackFrame.origin.x = -_blankXBias;
    trackFrame.size.width += _blankXBias;
    _trackLayer.frame = trackFrame;
    
    [_trackLayer setNeedsDisplay];

    _knobWidth = self.bounds.size.width;
    _useableTrackLength = self.bounds.size.height;

    
//    float upperKnobCentre = [self positionForValue:_upperValue];
//
//    
//    _upperKnobLayer.frame = CGRectMake(-30, upperKnobCentre - _knobWidth / 2, _knobWidth, _knobWidth);
//
//    float lowerKnobCentre = [self positionForValue:_lowerValue];
//    
//    _lowerKnobLayer.frame = CGRectMake(-30, lowerKnobCentre - _knobWidth / 2, _knobWidth, _knobWidth);
//    


    
//    // Control the visibility of the knob layer
//    if ((self.lowerValue > -1) && (self.upperValue < 0))
//    {
//        [_lowerKnobLayer setHidden:NO];
//        [_upperKnobLayer setHidden:YES];
//    [_lowerKnobLayer setNeedsDisplay];
//    }else if ((self.lowerValue > -1) && (self.upperValue > -1))
//    {
//        [_lowerKnobLayer setHidden:NO];
//        [_upperKnobLayer setHidden:NO];
//    [_lowerKnobLayer setNeedsDisplay];
//    [_upperKnobLayer setNeedsDisplay];
//    }else{
//        [_lowerKnobLayer setHidden:YES];
//        [_upperKnobLayer setHidden:YES];
//    }
    
}
                                           
- (float) positionForValue:(float)value
{
    return _useableTrackLength * (value - _minimumValue) /
        (_maximumValue - _minimumValue);
    
//    return _useableTrackLength * (value - _minimumValue) /
//    (_maximumValue - _minimumValue) + (_knobWidth / 2);
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan is called!");
    
    NSLog(@"# of touches in event: %lu", [[event allTouches] count]);
    
    for (UITouch *aTouch in touches){
        if (![self.trackTouchingSet containsObject:aTouch])
        {
            [self.trackTouchingSet addObject:aTouch];
        }
    }
    
    [self updateLowerUpperValues];
    [self setLayerFrames];
}

#define BOUND(VALUE, UPPER, LOWER)	MIN(MAX(VALUE, LOWER), UPPER)


- (void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self updateLowerUpperValues];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES] ;
    
    [self setLayerFrames];
    
    [CATransaction commit];
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    for (UITouch *aTouch in touches){
        [self.trackTouchingSet removeObject:aTouch];
    }
    [self updateLowerUpperValues];
    [self setLayerFrames];
}

- (void) updateLowerUpperValues{
    
    if ([_trackTouchingSet count] == 0){
        _lowerValue = -1;
        _upperValue = -1;
        
        [_upperKnobLayer setHidden:YES];
        [_lowerKnobLayer setHidden:YES];
        
    }else if ([_trackTouchingSet count] == 1){
        CGPoint touchPoint = [[_trackTouchingSet anyObject]
                              locationInView:self];
        float aValue = touchPoint.y / _useableTrackLength
        * (_maximumValue - _minimumValue);
        
        _lowerValue = aValue;
        _upperValue = -1;

        if (delegateRespondsTo.sliderOnePointTouched)
        {
            [self.delegate sliderOnePointTouched];
        }        
        
    }else if ([_trackTouchingSet count] == 2){
        float twoValues[2];
        
        // To detect _upperValue and _lowerValue
        int i = 0;
        for (UITouch *aTouch in self.trackTouchingSet){
            CGPoint touchPoint = [aTouch locationInView:self];
            
            twoValues[i] = touchPoint.y / _useableTrackLength
            * (_maximumValue - _minimumValue);
            i++;
        }
        _lowerValue = MIN(twoValues[0], twoValues[1]);
        _upperValue = MAX(twoValues[0], twoValues[1]);
        
        if (delegateRespondsTo.sliderTwoPOintsTouched){
            [self.delegate sliderTwoPOintsTouched];
        }
    }
}

@end
