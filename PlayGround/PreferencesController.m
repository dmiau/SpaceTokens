//
//  PreferencesController.m
//  SpaceBar
//
//  Created by Daniel on 7/18/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "PreferencesController.h"
#import "AppDelegate.h"
#import "CustomTabController.h"
#import "StudyManager/StudyManager.h"

@implementation PreferencesController

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
        
        // Connect to the parent view controller to update its
        // properties directly
        
        //-------------------
        // Set the rootViewController
        //-------------------
        AppDelegate *app = [[UIApplication sharedApplication] delegate];
        
        UINavigationController *myNavigationController =
        app.window.rootViewController;
        self.rootViewController = [myNavigationController.viewControllers objectAtIndex:0];
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated{
    CustomTabController *tabController = (CustomTabController *) self.parentViewController;
    
    // Control the title bar
    tabController.navigationBar.topItem.title = @"General";
    
    // Update the setting of the map segment controller
    if (self.rootViewController.mapView.mapType == MKMapTypeStandard){
        self.mapSegmentControl.selectedSegmentIndex = 0;
    }else if (self.rootViewController.mapView.mapType == MKMapTypeHybrid){
        self.mapSegmentControl.selectedSegmentIndex = 1;
    }else if (self.rootViewController.mapView.mapType == MKMapTypeSatelliteFlyover){
        self.mapSegmentControl.selectedSegmentIndex = 2;
    }
    
    int selectionIndex = 0;
    switch (self.rootViewController.studyManager.studyManagerStatus) {
        case OFF:
            selectionIndex = 0;
            break;
        case DEMO:
            selectionIndex = 1;
            break;
        case STUDY:
            selectionIndex = 2;
            break;
        case AUTHORING:
            selectionIndex = 3;
            break;
        default:
            break;
    }
    self.appModeSegmentControlOutlet.selectedSegmentIndex = selectionIndex;
}

//------------------
// Select map style
//------------------
- (IBAction)mapStyleSegmentControl:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSString *label = [segmentedControl
                       titleForSegmentAtIndex: [segmentedControl selectedSegmentIndex]];
    
    if ([label isEqualToString:@"Standard"]){
        self.rootViewController.mapView.mapType = MKMapTypeStandard;
    }else if ([label isEqualToString:@"Hybrid"]){

        self.rootViewController.mapView.mapType = MKMapTypeHybridFlyover;
    }else if ([label isEqualToString:@"Satellite"]){

        self.rootViewController.mapView.mapType = MKMapTypeSatelliteFlyover;
    }
}

- (IBAction)appModeSegmentControl:(id)sender {
    
    
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSString *label = [segmentedControl
                       titleForSegmentAtIndex: [segmentedControl selectedSegmentIndex]];
    
    if ([label isEqualToString:@"Normal"]){
        self.rootViewController.studyManager.studyManagerStatus = OFF;
        
        // Show the default view
        [self.rootViewController.mainViewManager showDefaultPanel];        
    }else if ([label isEqualToString:@"Demo"]){
        self.rootViewController.studyManager.studyManagerStatus = DEMO;
    }else if ([label isEqualToString:@"Study"]){
        self.rootViewController.studyManager.studyManagerStatus = STUDY;
        
        // Add the filter to the main view
        [self.rootViewController.mainViewManager showPanelWithType:CIRCLECHECKING];
        
    }else if ([label isEqualToString:@"Authoring"]){
        self.rootViewController.studyManager.studyManagerStatus = AUTHORING;
    }
}
@end
