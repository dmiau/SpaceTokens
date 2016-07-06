//
//  SpaceMark.h
//  SpaceBar
//
//  Created by Daniel on 2/1/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "POI.h"

@interface SpaceMark : POI


@property NSNumber *hasReportedDraggingEvent;
@property CAShapeLayer *circleLayer;
@property CAShapeLayer *lineLayer;

// When a SpaceMark is dragged out, a copy of the current SpaceMark is created (to stay in the docking position), while the current one moves out of the dock.
@property (weak) SpaceMark *counterPart;
- (void) resetButton;
@end
