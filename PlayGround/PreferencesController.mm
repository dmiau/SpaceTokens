//
//  PreferencesController.m
//  NavTools
//
//  Created by Daniel on 7/18/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "PreferencesController.h"
#import "AppDelegate.h"
#import "CustomTabController.h"
#import "StudyManager/GameManager.h"
#import "Map/Route.h"
#import "MainViewManager.h"
#import <AVFoundation/AVFoundation.h>
#import "CustomMKMapView.h"
#import "TokenCollection.h"
#import "EntityDatabase.h"
#import "HighlightedEntities.h"

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
    tabController.navigationBar.topItem.title = @"Settings";
    
    // Update the setting of the map segment controller
    if([self.rootViewController.panoView superview]){
        // This need to be the first
        self.mapSegmentControl.selectedSegmentIndex = 3;
    }else if (self.rootViewController.mapView.mapType == MKMapTypeStandard){
        self.mapSegmentControl.selectedSegmentIndex = 0;
    }else if (self.rootViewController.mapView.mapType == MKMapTypeHybrid){
        self.mapSegmentControl.selectedSegmentIndex = 1;
    }else if (self.rootViewController.mapView.mapType == MKMapTypeSatelliteFlyover){
        self.mapSegmentControl.selectedSegmentIndex = 2;
    }
    
    int selectionIndex = 0;
    switch (self.rootViewController.gameManager.gameManagerStatus) {
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
    
    if (self.rootViewController.mapView.isLongPressEnabled){
        self.longPressSegmentOutlet.selectedSegmentIndex = 1;
    }else{
        self.longPressSegmentOutlet.selectedSegmentIndex = 0;
    }
    
    // TransportType segment control
    MKDirectionsTransportType transportType = self.rootViewController.mapView.transportType;
    switch (transportType) {
        case MKDirectionsTransportTypeAutomobile:
            self.transportTypeOutlet.selectedSegmentIndex = 0;
            break;
        case MKDirectionsTransportTypeWalking:
            self.transportTypeOutlet.selectedSegmentIndex = 1;
            break;
        case MKDirectionsTransportTypeTransit:
            self.transportTypeOutlet.selectedSegmentIndex = 2;
            break;
        case MKDirectionsTransportTypeAny:
            self.transportTypeOutlet.selectedSegmentIndex = 3;
            break;
    }
    
    if (self.rootViewController.miniMapView.syncRotation){
        self.syncMiniMapRotationOutlet.selectedSegmentIndex = 1;
    }else{
        self.syncMiniMapRotationOutlet.selectedSegmentIndex = 0;
    }
    
    // Update the screen capture switch
    [self.screenCaptureSwitchOutlet setOn: !self.rootViewController.screenCaptureButton.isHidden];
    
    // Display debug info
    [self displayDebugInfo];
}

//------------------
// Select map style
//------------------
- (IBAction)mapStyleSegmentControl:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSString *label = [segmentedControl
                       titleForSegmentAtIndex: [segmentedControl selectedSegmentIndex]];
    
    if ([label isEqualToString:@"Standard"]){
        [self.rootViewController.mainViewManager showDefaultPanel];
        self.rootViewController.mapView.mapType = kGMSTypeNormal;
    }else if ([label isEqualToString:@"Hybrid"]){
        [self.rootViewController.mainViewManager showDefaultPanel];
        self.rootViewController.mapView.mapType = kGMSTypeHybrid;
    }else if ([label isEqualToString:@"Satellite"]){
        [self.rootViewController.mainViewManager showDefaultPanel];
        self.rootViewController.mapView.mapType = kGMSTypeSatellite;
    }else if ([label isEqualToString:@"StreetView"]){
        [self.rootViewController.mainViewManager
         showPanelWithType:STREETVIEWPANEL];
    }
}

- (IBAction)appModeSegmentControl:(id)sender {
    
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSString *label = [segmentedControl
                       titleForSegmentAtIndex: [segmentedControl selectedSegmentIndex]];
    
    if ([label isEqualToString:@"Normal"]){
        self.rootViewController.gameManager.gameManagerStatus = OFF;
    }else if ([label isEqualToString:@"Demo"]){
        self.rootViewController.gameManager.gameManagerStatus = DEMO;
    }else if ([label isEqualToString:@"Study"]){
        self.rootViewController.gameManager.gameManagerStatus = STUDY;
    }else if ([label isEqualToString:@"Authoring"]){
        self.rootViewController.gameManager.gameManagerStatus = AUTHORING;
    }
}

- (IBAction)syncMiniMapRotationAction:(id)sender {
    
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSString *label = [segmentedControl
                       titleForSegmentAtIndex: [segmentedControl selectedSegmentIndex]];
    
    if ([label isEqualToString:@"No"]){
        self.rootViewController.miniMapView.syncRotation = NO;
    }else if ([label isEqualToString:@"Yes"]){
        self.rootViewController.miniMapView.syncRotation = YES;
    }
}


-(void)displayDebugInfo{
    NSMutableArray *lineArray = [NSMutableArray array];
    [lineArray addObject: [[CustomMKMapView sharedManager] description]];
    [lineArray addObject: [[TokenCollection sharedManager] description]];
    [lineArray addObject: [[NavTools sharedManager] description]];
    [lineArray addObject: [[EntityDatabase sharedManager] description]];
    [lineArray addObject: [[HighlightedEntities sharedManager] description]];
    self.debugInfoOutlet.text = [lineArray componentsJoinedByString:@"\n"];
}

- (IBAction)longPressSegmentAction:(id)sender {
    self.rootViewController.mapView.isLongPressEnabled =
    !self.rootViewController.mapView.isLongPressEnabled;
}


- (IBAction)transportTypeAction:(id)sender {
    MKDirectionsTransportType transportType;
    switch (self.transportTypeOutlet.selectedSegmentIndex) {
        case 0:
            transportType = MKDirectionsTransportTypeAutomobile;
            break;
        case 1:
            transportType = MKDirectionsTransportTypeWalking;
            break;
        case 2:
            transportType = MKDirectionsTransportTypeTransit;
            break;
        case 3:
            transportType = MKDirectionsTransportTypeAny;
            break;
    }
    self.rootViewController.mapView.transportType = transportType;
}

// Screen Capture Switch Action
- (IBAction)screenCaptureSwtichAction:(id)sender {
    [self.rootViewController.screenCaptureButton setHidden:
    !self.rootViewController.screenCaptureButton.isHidden];
    
    [self.screenCaptureSwitchOutlet setOn: !self.rootViewController.screenCaptureButton.isHidden];
}
@end
