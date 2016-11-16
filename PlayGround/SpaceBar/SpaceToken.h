//
//  SpaceToken.h
//  SpaceBar
//
//  Created by Daniel on 2/1/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "POI.h"

@class Person;

typedef enum {DOCKED, DRAGGING, ANCHORTOKEN} TokenAppearanceType;

//----------------------------------------
// SpaceToken interface
//----------------------------------------
@interface SpaceToken : UIButton{
    CGPoint initialTouchLocationInView;
    BOOL hasReportedDraggingEvent;
    NSTimer *anchorVisualTimer;
}


@property BOOL isCircleLayerOn;
@property BOOL isLineLayerOn;
@property BOOL isConstraintLineOn;
@property BOOL isDraggable;

@property (weak) UITouch *touch; // to keep tracking of UITouch

@property CAShapeLayer *circleLayer; // signifies the touch poing
@property CAShapeLayer *lineLayer; // shows the line connecting the SpaceToken and the actual location
@property CAShapeLayer *constraintLayer; //used in the relaxed constraint state

// When a SpaceToken is dragged out, a copy of the current SpaceToken is created (to stay in the docking position), while the current one moves out of the dock.
@property (weak) SpaceToken *counterPart;
@property TokenAppearanceType appearanceType;
@property (strong) POI* poi;
@property Person* person; // A SpaceToken can be linked to a Person object

@property CGPoint mapViewXY;
// mapViewXY caches the Mercator (x, y) coordinates
// corrresponding to latlon


// display the anchor circle after some seconds
- (void)showAnchorVisualIndicatorAfter:(double) second;

// Exposing the button methods so the buttons can be touched programmatically
- (void) buttonDown:(UIButton*) sender forEvent:(UIEvent*)event;
- (void) buttonUp:(UIButton*)sender forEvent:(UIEvent*)event;
- (void) buttonDragging:(UIButton *)sender forEvent: (UIEvent *)event;


// Internal methods
- (void) registerButtonEvents;
- (void) configureAppearanceForType: (TokenAppearanceType) type;
@end
