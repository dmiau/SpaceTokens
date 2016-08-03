//
//  MainViewManager.h
//  SpaceBar
//
//  Created by Daniel on 8/3/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "topPanel.h"

typedef enum {SEARCH, DIRECTION} PanelType;
@class ViewController;
@class DirectionPanel;
@class SearchPanel;

//-------------------------
// ManViewManager
//-------------------------
@interface MainViewManager : NSObject

@property id<TopPanel> activePanel;
@property ViewController *rootViewController;


// Pointers to all the panels
@property DirectionPanel *directionPanel;
@property SearchPanel *searchPanel;


- (id) initWithViewController:(ViewController*) viewController;
- (void)showDefaultPanel;
- (void)showPanelWithType: (PanelType)panelType;
@end
