//
//  MainViewManager.m
//  SpaceBar
//
//  Created by Daniel on 8/3/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "MainViewManager.h"
#import "ViewController.h"
#import "Views/DirectionPanel.h"
#import "Views/SearchPanel.h"
#import "Views/CircleCheckingPanel.h"
#import "Views/TaskBasePanel.h"

@implementation MainViewManager

- (id)initWithViewController:(ViewController *)viewController
{
    self = [super init];
    if (self){
        self.rootViewController = viewController;
        
        // Infer the top panel height
        float topPanelHeight = self.rootViewController.view.frame.size.height -
        self.rootViewController.mapView.frame.size.height;
        
        // Initialize all the panels
        self.searchPanel = [[SearchPanel alloc]
                            initWithFrame:
                            CGRectMake(0, 0, self.rootViewController.view.frame.size.width, topPanelHeight)
                            ViewController:self.rootViewController];
        [self showDefaultPanel];
        
        self.directionPanel = [[DirectionPanel alloc] initWithFrame:
                               CGRectMake(0, 0, self.rootViewController.view.frame.size.width, topPanelHeight)
                                                     ViewController:self.rootViewController];
        self.circleCheckingPanel = [[CircleCheckingPanel alloc] initWithFrame:
                                    CGRectMake(0, 0, self.rootViewController.view.frame.size.width, topPanelHeight)
                                                          ViewController:self.rootViewController];
        
        self.taskBasePanel = [[TaskBasePanel alloc] initWithFrame:
                                    CGRectMake(0, 0, self.rootViewController.view.frame.size.width, topPanelHeight)
                                                               ViewController:self.rootViewController];
        
    }
    return self;
}

- (void)removeActivePanel{
    [self.activePanel removePanel];
    UIView *tempView = (UIView*) self.activePanel;
    [tempView removeFromSuperview];
}

- (void)showPanelWithType: (PanelType)panelType{
    switch (panelType) {
        case SEARCH:
            [self showDefaultPanel];
            break;
        case DIRECTION:
            [self showDirectionPanel];
            break;
        case CIRCLECHECKING:
            [self showCircleCheckingPanel];
            break;
        case TASKBASEPANEL:
            [self showTaskBasePanel];
            break;
        default:
            break;
    }
}

- (void)showDefaultPanel{
    [self removeActivePanel];
    [self.searchPanel addPanel];
    self.activePanel = self.searchPanel;
    
    // Remove the filter panel
    if (self.filterPanel){
        UIView *tempPanel = (UIView*) self.filterPanel;
        [tempPanel removeFromSuperview];
        self.filterPanel = nil;
    }
}

- (void)showDirectionPanel{
    [self removeActivePanel];
    // add the panel to the main view if it has been instantiated
    [self.directionPanel addPanel];
    self.activePanel = self.directionPanel;
}

- (void)showTaskBasePanel{
    [self removeActivePanel];
    // add the panel to the main view if it has been instantiated
    [self.taskBasePanel addPanel];
    self.activePanel = self.taskBasePanel;
}

- (void)showCircleCheckingPanel{
    [self.circleCheckingPanel addPanel];
    self.filterPanel = self.circleCheckingPanel;
}

@end