//
//  MainViewManager.h
//  SpaceBar
//
//  Created by Daniel on 8/3/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "topPanel.h"

typedef enum {SEARCH, DIRECTION, TASKBASEPANEL,
    STREETVIEWPANEL, AUTHORINGPANEL, SHOWAUTHORINGPANEL} PanelType;
@class ViewController;
@class DirectionPanel;
@class SearchPanel;
@class TaskBasePanel;
@class StreetViewPanel;
@class AuthoringPanel;
@class SearchPanelView;
@class ShowAuthoringPanel;

//-------------------------
// ManViewManager
//-------------------------
@interface MainViewManager : NSObject

@property id<TopPanel> activePanel;
@property id<TopPanel> filterPanel;
@property ViewController *rootViewController;


// Pointers to all the panels
@property DirectionPanel *directionPanel;
@property SearchPanelView *searchPanel;
@property TaskBasePanel *taskBasePanel;
@property StreetViewPanel *streetViewPanel;
@property AuthoringPanel *authoringPanel;
@property ShowAuthoringPanel *authoringPanelShowTask;

- (id) initWithViewController:(ViewController*) viewController;
- (void)showDefaultPanel;
- (void)showPanelWithType: (PanelType)panelType;
@end
