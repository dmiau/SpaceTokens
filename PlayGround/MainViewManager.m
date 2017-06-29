//
//  MainViewManager.m
//  NavTools
//
//  Created by Daniel on 8/3/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "MainViewManager.h"
#import "ViewController.h"
#import "Views/DirectionPanel.h"

#import "TaskBasePanel.h"
#import "StreetViewPanel.h"
#import "AuthoringPanel.h"
#import "ShowAuthoringPanel.h"
#import "SearchPanelView.h"
#import "EntityDatabase.h"
#import "TokenCollectionView.h"

@implementation MainViewManager
static MainViewManager *sharedInstance;

+ (MainViewManager*)sharedManager{
    
    if (!sharedInstance){
        [NSException raise:@"Programming error." format:@"MainViewManager shared instance was requested before it was initialized."];
    }
    return sharedInstance;
}

- (id)initWithViewController:(ViewController *)viewController
{
    self = [super init];
    if (self){
        self.rootViewController = viewController;
        
        // Infer the top panel height
        float topPanelHeight = self.rootViewController.view.frame.size.height -
        self.rootViewController.mapView.frame.size.height;
        
        
        self.directionPanel = [[DirectionPanel alloc] initWithFrame:
                               CGRectMake(0, 0, self.rootViewController.view.frame.size.width, topPanelHeight)
                                                     ViewController:self.rootViewController];
        
        self.streetViewPanel = [[StreetViewPanel alloc] initWithFrame:
                              CGRectMake(0, 0, self.rootViewController.view.frame.size.width, topPanelHeight)
                                                   ViewController:self.rootViewController];
        
        //----------------------
        // Load the task panel
        //----------------------
        // Note this method needs to be here
        NSArray *view_array =
        [[NSBundle mainBundle] loadNibNamed:@"TaskBasePanel"
                                      owner:self options:nil];
        
        for (UIView *aView in view_array){
            if ([[aView restorationIdentifier] isEqualToString:@"TaskBasePanel"]){
                self.taskBasePanel = (TaskBasePanel*) aView;
                // This is necessary so iPad will get the right view size
                [self.taskBasePanel setFrame:self.rootViewController.view.frame];
            }
        }
        
        //----------------------
        // Load the AuhoringPanel
        //----------------------
        self.authoringPanel = [[[NSBundle mainBundle] loadNibNamed:@"AuthoringView" owner:self options:nil] firstObject];
        
        // Load the ShowAuthoring panel
        self.authoringPanelShowTask = [[[NSBundle mainBundle] loadNibNamed:@"ShowAuthoringPanel" owner:self options:nil] firstObject];
        
        //--------------------
        // Load the search panel
        //--------------------
        
        // Note this method needs to be here
        view_array =
        [[NSBundle mainBundle] loadNibNamed:@"SearchPanel"
                                      owner:self options:nil];
        
        for (UIView *aView in view_array){
            if ([[aView restorationIdentifier] isEqualToString:@"SearchPanel"]){
                self.searchPanel = (SearchPanelView*) aView;
            }
        }
        
        [self showDefaultPanel];
        
    }
    sharedInstance = self;
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
        case TASKBASEPANEL:
            [self showTaskBasePanel];
            break;
        case AUTHORINGPANEL:
            [self showAuthoringPanel];
            break;
        case SHOWAUTHORINGPANEL:
            [self showAuthoringPanelShowTask];
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

- (void)showStreetViewPanel{
    [self removeActivePanel];
    // add the panel to the main view if it has been instantiated
    [self.streetViewPanel addPanel];
    self.activePanel = self.streetViewPanel;
}


- (void)showAuthoringPanel{
    [self removeActivePanel];
    // add the panel to the main view if it has been instantiated
    [self.authoringPanel addPanel];
    self.activePanel = self.authoringPanel;
}

- (void)showAuthoringPanelShowTask{
    [self removeActivePanel];
    
    [self.authoringPanelShowTask addPanel];
    self.activePanel = self.authoringPanelShowTask;
}

@end
