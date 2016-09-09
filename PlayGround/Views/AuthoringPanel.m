//
//  AuthoringPanel.m
//  SpaceBar
//
//  Created by dmiau on 9/9/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "AuthoringPanel.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "SettingsButton.h"
#import "SnapshotProgress.h"
#import "SnapshotChecking.h"
#import "GameManager.h"

#import "SnapshotPlace.h"
#import "SnapshotAnchorPlus.h"

@implementation AuthoringPanel{
    SettingsButton *settingsButton;
    Snapshot *snapShot;
    NSMutableArray *activeCaptureArray;
 
    CGRect targetRectBox;
    CAShapeLayer *authoringVisualAidLayer;
}

static AuthoringPanel *instance;

+(id)sharedManager {return instance;};

+ (id) hiddenAlloc
{
    return [super alloc];
}


+(id)alloc
{
    return [self sharedManager];
}

+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        instance = [[AuthoringPanel hiddenAlloc] init];
    }
}


- (id)init
{
    if(instance==nil) // allow only to be called once
    {
        // your normal initialization here
        
        // Connect to the parent view controller to update its
        // properties directly
        
        //-------------------
        // Set the rootViewController
        //-------------------
        AppDelegate *app = [[UIApplication sharedApplication] delegate];
        
        UINavigationController *myNavigationController =
        app.window.rootViewController;
        self.rootViewController = [myNavigationController.viewControllers objectAtIndex:0];
        
        //-------------------
        // Set up the view
        //-------------------
        // set up the color of the view
        [self setBackgroundColor:[UIColor colorWithRed: 0.94 green:0.94 blue:0.94
                                                 alpha:1.0]];
        settingsButton = [[SettingsButton alloc] init];
        
        authoringVisualAidLayer = [CAShapeLayer layer];
    }
    return self;
}

#pragma mark --Top Panel protocol methods--

- (id)initWithFrame:(CGRect)frame ViewController:(ViewController*) viewController{
    
    self = [TaskBasePanel sharedManager];
    self.frame = frame;
    if (self){
        
    }
    
    return self;
}

- (void)addPanel{
    
    float panelHeight = self.rootViewController.view.frame.size.height -
    self.rootViewController.mapView.frame.size.height;
    // Move the map to the top
    float mapWidth = self.rootViewController.mapView.frame.size.width;
    float mapHeight = self.rootViewController.mapView.frame.size.height;
    self.rootViewController.mapView.frame = CGRectMake(0, 0, mapWidth, mapHeight);
    
    // Set up the frame of the panel
    self.frame = CGRectMake(0, mapHeight, mapWidth, panelHeight);
    [self.rootViewController.view addSubview:self];
    
    // Add the preference button
    settingsButton.frame = CGRectMake(0, 30, 30, 30);
    [self.rootViewController.view addSubview: settingsButton];
    
    self.isAuthoringVisualAidOn = YES;
}


- (void)removePanel{
    // Remove the settings button
    [settingsButton removeFromSuperview];
    [self removeFromSuperview];
    
    // Restore the location of the map
    float panelHeight = self.rootViewController.view.frame.size.height -
    self.rootViewController.mapView.frame.size.height;
    // Move the map to the top
    float mapWidth = self.rootViewController.mapView.frame.size.width;
    float mapHeight = self.rootViewController.mapView.frame.size.height;
    self.rootViewController.mapView.frame = CGRectMake(0, panelHeight, mapWidth, mapHeight);
    
    self.isAuthoringVisualAidOn = NO;
}

#pragma mark --Target Visual Aids--
- (void)setIsAuthoringVisualAidOn:(BOOL)isAuthoringVisualAidOn{
    
    // Get the map object
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    
    if (isAuthoringVisualAidOn){
        // Draw a cirlce in the middle of the display
        // Get the width and height
        float width = mapView.frame.size.width;
        float height = mapView.frame.size.height;
        float diameter = 0.8 * width;
        CGRect targetRectBox = CGRectMake(0.1*width, (height - diameter)/2, diameter, diameter);
        
        // Draw a circle
        [authoringVisualAidLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:targetRectBox] CGPath]];
        [authoringVisualAidLayer setStrokeColor:[[UIColor greenColor] CGColor]];
        [authoringVisualAidLayer setFillColor:[[UIColor clearColor] CGColor]];
        [[mapView layer] addSublayer:authoringVisualAidLayer];
    }else{
        // Remove the cirlce
        [authoringVisualAidLayer removeFromSuperlayer];
    }
}


-(MKCoordinateRegion)getTargetCoordinatRegion{
    // Get the map object
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    
    // Get the
    
    MKCoordinateRegion coordinateRegion = [mapView convertRect:targetRectBox
                                              toRegionFromView:mapView];
    return coordinateRegion;
}

#pragma mark --Authoring Actions--

- (IBAction)taskTypeAction:(id)sender {
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

- (IBAction)startEndAction:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSString *label = [segmentedControl
                       titleForSegmentAtIndex: [segmentedControl selectedSegmentIndex]];
    
    if ([label isEqualToString:@"Start"]){
        activeCaptureArray = snapShot.highlightedPOIs;
    }else if ([label isEqualToString:@"End"]){
        activeCaptureArray = snapShot.targetedPOIs;
    }
}

- (IBAction)captureAction:(id)sender {    
    // Save the current map parameters
    MKCoordinateRegion coordinateRegion = [self getTargetCoordinatRegion];
    
    // Construct a POI
    POI *poi = [[POI alloc] init];
    poi.latLon = coordinateRegion.center;
    poi.coordSpan = coordinateRegion.span;
    
    [activeCaptureArray addObject: poi];
}

- (IBAction)addAction:(id)sender {
    
    // Get the SnapshotDatabase
    SnapshotDatabase *snapshotDatabase = [SnapshotDatabase sharedManager];
    
    // Generate a name
    NSDateFormatter *formatter;
    NSString        *dateString;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    
    dateString = [formatter stringFromDate:[NSDate date]];
    NSString *prefix = SnapshotTypeToPrefix(snapShot);
    NSString *snapshotName = [NSString stringWithFormat:@"%@:%@", prefix, dateString];
    
    // Put the snapshot into SnapshotDatabase
    snapshotDatabase.snapshotDictrionary[snapshotName] = snapShot;
}

// A helper function
NSString* SnapshotTypeToPrefix( Snapshot *aSnapshot){
    NSString *prefix;
    if ([aSnapshot isKindOfClass:[SnapshotPlace class]]){
        prefix = @"Place";
    }else if ([aSnapshot isKindOfClass:[SnapshotAnchorPlus class]]){
        prefix = @"Anchors";
    }
    return prefix;
}

@end
