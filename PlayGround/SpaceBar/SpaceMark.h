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

@property (weak) SpaceMark *counterPart;
- (void) resetButton;
@end
