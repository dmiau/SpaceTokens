//
//  StreetViewPanel.m
//  NavTools
//
//  Created by dmiau on 8/14/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "StreetViewPanel.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "SettingsButton.h"
#import <MapKit/MapKit.h>
#import "EntityDatabase.h"
#import "Person.h"
#import "TokenCollectionView.h"
#import "Constants.h"

@implementation StreetViewPanel{
    SettingsButton *settingsButton;
    CGRect cachedMapFrame;
}

-(id)initWithFrame: (CGRect)frame ViewController:(ViewController*) viewController{
    self = [super initWithFrame:frame];
    if (self){
        self.rootViewController = viewController;
        //----------------
        // Initialize StreetView
        //----------------
        self.panoView = [[GMSPanoramaView alloc]
                         initWithFrame: self.frame]; //dummy initialization
        self.panoView.delegate = self;
        self.rootViewController.panoView = self.panoView; // cache a pointer in the main ViewController
        
        settingsButton = [[SettingsButton alloc] init];
    }
    return self;
}

-(void)addPanel{
    
    // Calculate the StreetView height
    float streetViewHeight = self.rootViewController.view.frame.size.height*0.35;
    
    // Add the StreetView
    self.panoView.frame =
    CGRectMake(0, 0,
               self.rootViewController.view.frame.size.width,
               streetViewHeight);
    [self.rootViewController.view addSubview:self.panoView];
    
    // Adjust the size of the map
    cachedMapFrame = self.rootViewController.mapView.frame;

    self.rootViewController.mapView.frame =
    CGRectMake(0, streetViewHeight,
               self.rootViewController.view.frame.size.width,
               self.rootViewController.view.frame.size.height-
               streetViewHeight);
    
    // Position the map and StreetView to Paris
    [self.panoView moveNearCoordinate:CLLocationCoordinate2DMake(48.857624, 2.351482)];
    
    GMSCameraPosition *paris = [GMSCameraPosition cameraWithLatitude:48.857624
                                                            longitude:2.351482
                                                                 zoom:15];
    
    [self.rootViewController.mapView setCamera:paris];
    
    // Add the preference button
    [self.rootViewController.view addSubview: settingsButton];    
}

-(void)viewWillAppear:(BOOL)animated{
    [TokenCollectionView sharedManager].isVisible = YES;
    //This will reset the position of the TokenCollectionView frame
    
    // listen to several notification of interest
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(mapUpdateHandler)
                   name:MapUpdatedNotification
                 object:nil];
    
    // Draw a dot at the center
//    CAShapeLayer *circleLayer = [CAShapeLayer layer];
//    [circleLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(50, 50, 100, 100)] CGPath]];
    
    [self.rootViewController updateUIPlacement];
}

-(void)removePanel{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [settingsButton removeFromSuperview];
    // Hide the StreetView
    [self.panoView removeFromSuperview];
    self.rootViewController.mapView.frame = cachedMapFrame; // Move the map back
}

- (void)mapUpdateHandler{
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    
    // Position the map and StreetView to Paris
    [self.panoView moveNearCoordinate: mapView.camera.target];
}


// Panorama is moved. Need to update the user's location
- (void)panoramaView:(GMSPanoramaView *)view didMoveToPanorama:(GMSPanorama *)panorama{
    
    // Also update the YouAreHere indicator
    [EntityDatabase sharedManager].youRHere.latLon = panorama.coordinate;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
