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
#import "Views/StreetViewPanel.h"
#import "Views/AuthoringPanel.h"

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
        
        self.streetViewPanel = [[StreetViewPanel alloc] initWithFrame:
                              CGRectMake(0, 0, self.rootViewController.view.frame.size.width, topPanelHeight)
                                                   ViewController:self.rootViewController];
        
        //----------------------
        // Load all the panels from xib
        //----------------------
        // Note this method needs to be here
        NSArray *view_array =
        [[NSBundle mainBundle] loadNibNamed:@"StudyPanels"
                                      owner:self options:nil];
        
        for (UIView *aView in view_array){
            if ([[aView restorationIdentifier] isEqualToString:@"TaskBasePanel"]){
                self.taskBasePanel = (TaskBasePanel*) aView;
            }else if([[aView restorationIdentifier] isEqualToString:@"AuthoringPanel"]){
                self.authoringPanel = (AuthoringPanel*) aView;
            }
        }
        
    }
    return self;
}

- (void)removeActivePanel{
    [self.activePanel removePanel];
    UIView *tempView = (UIView*) self.activePanel;
    [tempView removeFromSuperview];
}


#pragma mark -- Show Panels --
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
        case AUTHORINGPANEL:
            [self showAuthoringPanel];
            break;
        case STREETVIEWPANEL:
            [self showStreetViewPanel];
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
    
    // Refresh SpaceTokens
    [self.rootViewController.spaceBar removeAllSpaceTokens];
    [self.rootViewController.spaceBar
     addSpaceTokensFromPOIArray:self.rootViewController.poiDatabase.poiArray];
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

- (void)showAuthoringPanel{
    [self removeActivePanel];
    // add the panel to the main view if it has been instantiated
    [self.authoringPanel addPanel];
    self.activePanel = self.authoringPanel;
}

- (void)showCircleCheckingPanel{
    [self.circleCheckingPanel addPanel];
    self.filterPanel = self.circleCheckingPanel;
}


- (void)showStreetViewPanel{
    [self removeActivePanel];
    // add the panel to the main view if it has been instantiated
    [self.streetViewPanel addPanel];
    self.activePanel = self.streetViewPanel;
}
@end
