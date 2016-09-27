//
//  SpaceToken.h
//  SpaceBar
//
//  Created by Daniel on 2/1/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "../Map/POI.h"

@class Person;

typedef enum {DOCKED, DRAGGING, ANCHORTOKEN, DOT} spaceTokenType;

//--------------------
// SpaceToken interface
//--------------------
@interface SpaceToken : UIButton


@property BOOL hasReportedDraggingEvent;
@property CGPoint initialTouchLocationInView;
@property BOOL isCircleLayerOn;
@property BOOL isLineLayerOn;
@property BOOL isConstraintLineOn;
@property BOOL isDraggable;

@property (weak) UITouch *touch; // to keep tracking of UITouch

@property CAShapeLayer *circleLayer;
@property CAShapeLayer *lineLayer;
@property CAShapeLayer *constraintLayer;

// When a SpaceToken is dragged out, a copy of the current SpaceToken is created (to stay in the docking position), while the current one moves out of the dock.
@property (weak) SpaceToken *counterPart;
@property spaceTokenType type;
@property (strong) POI* poi;
@property Person* person; // A SpaceToken can be linked to a Person object

@property CGPoint mapViewXY;
// mapViewXY caches the Mercator (x, y) coordinates
// corrresponding to latlon

- (void) registerButtonEvents;

- (void) configureAppearanceForType: (spaceTokenType) type;

// Exposing the button methods so the buttons can be touched programmatically
- (void) buttonDown:(UIButton*) sender forEvent:(UIEvent*)event;
- (void) buttonUp:(UIButton*)sender forEvent:(UIEvent*)event;
- (void) buttonDragging:(UIButton *)sender forEvent: (UIEvent *)event;
@end
