//
//  MainViewManager.h
//  SpaceBar
//
//  Created by Daniel on 8/3/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "topPanel.h"

typedef enum {SEARCH, DIRECTION, CIRCLECHECKING, TASKCHECKING} PanelType;
@class ViewController;
@class DirectionPanel;
@class SearchPanel;
@class CircleCheckingPanel;
@class TaskCheckingPanel;

//-------------------------
// ManViewManager
//-------------------------
@interface MainViewManager : NSObject

@property id<TopPanel> activePanel;
@property id<TopPanel> filterPanel;
@property ViewController *rootViewController;


// Pointers to all the panels
@property DirectionPanel *directionPanel;
@property SearchPanel *searchPanel;
@property CircleCheckingPanel *circleCheckingPanel;
@property TaskCheckingPanel *taskCheckingPanel;

- (id) initWithViewController:(ViewController*) viewController;
- (void)showDefaultPanel;
- (void)showPanelWithType: (PanelType)panelType;
@end
