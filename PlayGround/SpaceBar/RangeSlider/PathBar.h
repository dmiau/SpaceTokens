//
//  PathBar.h
//  PathBar
//
//  Created by Colin Eberhardt on 22/03/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import <UIKit/UIKit.h>


@class PathBarTrackLayer;
@class Elevator;
@class Route;

#pragma mark - PathBarProtocol
//--------------------------------------------------------
// PathBar delegate methods
//--------------------------------------------------------
@protocol PathBarDelegate <NSObject>
- (void)spaceBarOnePointTouched:(float) percentage;
- (void)spaceBarTwoPointsTouchedLow:(float) low high: (float) high;
- (void)spaceBarElevatorMovedLow:(float) low high: (float) high fromLowToHigh: (bool) flag;
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

@property bool smallValueOnTopOfBar; //by default the small value is on top, user can use this flag to flip the default behavior

// Use bit field to track if delegate is set properly
//http://www.ios-blog.co.uk/tutorials/objective-c/how-to-create-an-objective-c-delegate/
@property struct {
unsigned int spaceBarOnePointTouched:1;
unsigned int spaceBarTwoPointsTouched:1;
unsigned int spaceBarElevatorMoved:1;
} delegateRespondsTo;


@property PathBarTrackLayer* trackLayer;
@property Elevator* elevator;
@property float useableTrackLength;
@property CGPoint previousTouchPoint;


+ (PathBar*)sharedManager; // Singleton initilization method


// Interface for outside to update the elevator
- (void) updateElevatorFromPercentagePair: (float[2]) percentagePair;


// --------------
// Implemented in annotation category
// --------------
@property UIView *annotationView;
- (void) addAnnotationsFromRoute:(Route *) route;
- (void) removeRouteAnnotations;



@end
