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
#import "StudyManager/GameManager.h"
#import "Map/Route.h"
#import "MainViewManager.h"
#import <AVFoundation/AVFoundation.h>

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
    
    // Update the status of the mini map
    if (!self.rootViewController.miniMapView.superview){
        self.miniMapOutlet.selectedSegmentIndex = 0;
    }else{
        self.miniMapOutlet.selectedSegmentIndex = 1;
    }
    
    if (self.rootViewController.miniMapView.syncRotation){
        self.syncMiniMapRotationOutlet.selectedSegmentIndex = 1;
    }else{
        self.syncMiniMapRotationOutlet.selectedSegmentIndex = 0;
    }    
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
        self.rootViewController.mapView.mapType = MKMapTypeStandard;
    }else if ([label isEqualToString:@"Hybrid"]){
        [self.rootViewController.mainViewManager showDefaultPanel];
        self.rootViewController.mapView.mapType = MKMapTypeHybridFlyover;
    }else if ([label isEqualToString:@"Satellite"]){
        [self.rootViewController.mainViewManager showDefaultPanel];
        self.rootViewController.mapView.mapType = MKMapTypeSatelliteFlyover;
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
- (IBAction)miniMapAction:(id)sender {
    
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSString *label = [segmentedControl
                       titleForSegmentAtIndex: [segmentedControl selectedSegmentIndex]];
    
    if ([label isEqualToString:@"On"]){
        [self.rootViewController.mapView addSubview: self.rootViewController.miniMapView];
        
        // Add the route if there is an active route
        
        if (self.rootViewController.spaceBar.activeRoute){
            [self.rootViewController.miniMapView zoomToFitRoute:self.rootViewController.spaceBar.activeRoute];
            // Remove previous routes if any
            [self.rootViewController.miniMapView removeRouteOverlays];
            
            [self.rootViewController.miniMapView
             addOverlay:self.rootViewController.spaceBar.activeRoute.route.polyline
             level:MKOverlayLevelAboveRoads];
        }
    }else if ([label isEqualToString:@"Off"]){
        [self.rootViewController.miniMapView removeFromSuperview];
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
- (IBAction)camSegmentAction:(UISegmentedControl*)sender {
    static AVCaptureVideoPreviewLayer *previewLayer;
    if (sender.selectedSegmentIndex == 1){
        AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];;
        previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
        UIView *aView = self.rootViewController.mapView;
        previewLayer.frame = aView.bounds; // Assume you want the preview layer to fill the view.
        [aView.layer addSublayer:previewLayer];
    }else{
        [previewLayer removeFromSuperlayer];
    }
    
}
@end
