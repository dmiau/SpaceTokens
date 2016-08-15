//
//  StreetViewPanel.m
//  SpaceBar
//
//  Created by dmiau on 8/14/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "StreetViewPanel.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import <MapKit/MapKit.h>


@implementation StreetViewPanel

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
    self.rootViewController.mapView.frame =
    CGRectMake(0, streetViewHeight,
               self.rootViewController.view.frame.size.width,
               self.rootViewController.view.frame.size.height-
               streetViewHeight);
    
    // Position the map and StreetView to Paris
    [self.panoView moveNearCoordinate:CLLocationCoordinate2DMake(48.857624, 2.351482)];
     
    [self.rootViewController.mapView
     setRegion: MKCoordinateRegionMake
     (CLLocationCoordinate2DMake(48.857624, 2.351482),
                        MKCoordinateSpanMake(0.003, 0.003))];
    
    // Manually set the user's location
    
}

-(void)removePanel{
    // Hide the StreetView
    [self.panoView removeFromSuperview];
}

// Panorama is moved. Need to update the user's location
- (void)panoramaView:(GMSPanoramaView *)view didMoveToPanorama:(GMSPanorama *)panorama{
    static int counter = 0;
    self.rootViewController.mapView.customUserLocation.coordinate =
    panorama.coordinate;
    
    NSString *temp  =[NSString stringWithFormat:@"%d", counter++];
    
    // Also update the YouAreHere indicator
    self.rootViewController.spaceBar.youAreHere.poi.name = temp; //update the name for debug purposes
    self.rootViewController.spaceBar.youAreHere.poi.latLon = panorama.coordinate;
    NSLog(@"StreetView name: %@", temp);
    NSLog(@"StreetView lat: %g lon: %g", panorama.coordinate.latitude, panorama.coordinate.longitude);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
