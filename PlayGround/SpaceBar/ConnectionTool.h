//
//  ConnectionTool.h
//  NavTools
//
//  Created by dmiau on 11/18/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SpaceToken;
@class SpaceBar;

@interface ConnectionTool : UIButton{
    CGPoint initialTouchLocationInView;
    CAShapeLayer *lineLayer; // shows the line connecting the SpaceToken and the actual location
    SpaceToken *counterPart;
    NSMutableArray <NSLayoutConstraint*> *constraintsArray;
    BOOL hasReportedDraggingEvent;
    
    UILabel *messageLabel;
}

@property BOOL isLineLayerOn;
@property BOOL isDraggable;


- (void)attachToSpaceToken:(SpaceToken*) spaceToken;

@end
