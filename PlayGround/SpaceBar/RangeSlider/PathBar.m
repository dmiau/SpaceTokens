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
#import "CustomMKMapView.h"



#define PATHBAR_WIDTH 40

@implementation PathBar

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
        
        _delegateRespondsTo.spaceBarOnePointTouched =
        [_delegate respondsToSelector:@selector(spaceBarOnePointTouched:)];
        _delegateRespondsTo.spaceBarTwoPointsTouched =
        [_delegate respondsToSelector:@selector(spaceBarTwoPointsTouchedLow:high:)];
        _delegateRespondsTo.spaceBarElevatorMoved =
        [_delegate respondsToSelector:@selector(spaceBarElevatorMovedLow: high: fromLowToHigh:)];
    }
}

- (void) redrawLayers
{
    [_trackLayer setNeedsDisplay];
}


//--------------------------------
// Initializations
//--------------------------------

+ (PathBar*)sharedManager{
    static PathBar* sharedInstance;
    if (!sharedInstance){
        
        CGRect frame = CGRectMake(0, 0,
                            PATHBAR_WIDTH,
                            [CustomMKMapView sharedManager].frame.size.height);
        
        sharedInstance = [[PathBar alloc] initWithFrame:frame];
        
        // Further initialization
        sharedInstance.trackPaddingInPoints = 60; //pad the top and bottom
        sharedInstance.curvatiousness = 0.0;
        
    }
    return sharedInstance;
}


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
        
        _smallValueOnTopOfBar = YES;
        
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
        
        
        // Init an annotation view to hold annotations
        self.annotationView = [[UIView alloc] initWithFrame:self.bounds];
        self.annotationView.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.annotationView];
        [self.annotationView setUserInteractionEnabled:NO];
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


@end
