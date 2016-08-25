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


@property NSNumber *hasReportedDraggingEvent;
@property CAShapeLayer *circleLayer;
@property CAShapeLayer *lineLayer;

// When a SpaceToken is dragged out, a copy of the current SpaceToken is created (to stay in the docking position), while the current one moves out of the dock.
@property (weak) SpaceToken *counterPart;
@property spaceTokenType type;
@property POI* poi;
@property Person* person; // A SpaceToken can be linked to a Person object

@property CGPoint mapViewXY;
// mapViewXY caches the Mercator (x, y) coordinates
// corrresponding to latlon

- (id) initForType: (spaceTokenType)type; // factory method

- (void) resetButton;
- (void) configureAppearanceForType: (spaceTokenType) type;
@end
