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

@implementation AuthoringPanel

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

#pragma mark --View Init--
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
        
        // Initiate the gesture view
        gestureView = [[UIView alloc] init];
        
        // Add a tap gesture recognizer
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(handleSingleTap:)];
        [gestureView addGestureRecognizer:singleTap];
        
    }
    return self;
}

#pragma mark --Top Panel protocol methods--

- (id)initWithFrame:(CGRect)frame ViewController:(ViewController*) viewController{
    
    self = [AuthoringPanel sharedManager];
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
//    self.rootViewController.mapView.frame = CGRectMake(0, 0, mapWidth, mapHeight);
    
    // Set up the frame of the panel
    self.frame = CGRectMake(0, 0, mapWidth, panelHeight);
    [self.rootViewController.view addSubview:self];
    
    // Set up the gestureView to capture gestures
    gestureView.frame = CGRectMake(0, 0, mapWidth, mapHeight);
    [gestureView setBackgroundColor:[UIColor blackColor]];
    gestureView.alpha = 0.4;
    
    // Calculate targetRectBox
    float diameter = 0.8 * mapWidth;
    targetRectBox = CGRectMake(0.1*mapWidth, (mapHeight - diameter)/2, diameter, diameter);
    
    // Add the preference button
    [self.rootViewController.view addSubview: settingsButton];
    
    self.isAuthoringVisualAidOn = NO;
    
    // Reset the interface
    [self resetInterface];
}


- (void)removePanel{
    // Remove the settings button
    [settingsButton removeFromSuperview];
    [self removeFromSuperview];
    
    // Remove the gesture layer
    [gestureView removeFromSuperview];
    
    // Restore the location of the map
    float panelHeight = self.rootViewController.view.frame.size.height -
    self.rootViewController.mapView.frame.size.height;
    // Move the map to the bottom
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
    
    MKCoordinateRegion coordinateRegion = [mapView convertRect:targetRectBox
                                              toRegionFromView:mapView];
    return coordinateRegion;
}

#pragma mark --Authoring Actions--

- (IBAction)taskTypeAction:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSString *label = [segmentedControl
                       titleForSegmentAtIndex: [segmentedControl selectedSegmentIndex]];
    [self restartAuthoringFlow];
    if ([label isEqualToString:@"Place"]){
        snapShot = [[SnapshotPlace alloc] init];
        // Enable some of the buttons
        [self.captureEndCondOutlet setEnabled:YES];
        [self.highlightedPOIOutlet setEnabled:NO];
    }else if ([label isEqualToString:@"Anchor"]){
        snapShot = [[SnapshotAnchorPlus alloc] init];
        // Disable some of the buttons
        [self.captureEndCondOutlet setEnabled:NO];
        [self.highlightedPOIOutlet setEnabled:YES];
    }else if ([label isEqualToString:@"Z-2-Pref"]){

    }else if ([label isEqualToString:@"Constraints"]){

    }
}


//----------------
// Capture the start condition
//----------------
- (IBAction)captureStartAction:(id)sender {
    // Draw the visual on the map
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    
    // Save the current map parameters
    MKCoordinateRegion coordinateRegion = mapView.region;
    snapShot.latLon = coordinateRegion.center;
    snapShot.coordSpan = coordinateRegion.span;
    
    // Need to get a square out of the rectangle
    MKMapRect mapRect = mapView.visibleMapRect;
    MKMapRect circleRect;
    
    // Assume the map is in portrait mode
    circleRect.origin = MKMapPointMake(mapRect.origin.x,
                                       mapRect.origin.y +
                                       (mapRect.size.height - mapRect.size.width)/2);
    circleRect.size.height = mapRect.size.width;
    circleRect.size.width = mapRect.size.width;
    
    
    MKCircle *circle = [MKCircle circleWithMapRect: circleRect];
    [mapView addOverlay:circle];
    
    // Update the label of the button
    [self.captureStartCondOutlet setTitle:@"Cap-StartCond(1)" forState:UIControlStateNormal];
}


//----------------
// Capture the end condition
//----------------
- (IBAction)captureEndAction:(id)sender {
//    self.isAuthoringVisualAidOn = YES;
    MKCoordinateRegion coordinateRegion = [self getTargetCoordinatRegion];
    POI *poi = [[POI alloc] init];
    poi.latLon = coordinateRegion.center;
    poi.coordSpan = coordinateRegion.span;
    
    [targetedPOIsArray addObject:poi];
    
    // Visualize the end circle
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    MKCircle *circle = [MKCircle circleWithMapRect:
                        [CustomMKMapView MKMapRectForCoordinateRegion:coordinateRegion]];
    [mapView addOverlay:circle];
    
    
    // Update the label of the button
    NSString *buttonLabel = [NSString stringWithFormat: @"Cap-EndCond(%lu)", [targetedPOIsArray count]];
    [self.captureEndCondOutlet setTitle:buttonLabel forState:UIControlStateNormal];
    
    textSinkObject = snapShot;
}

//----------------------
// Denote an anchor
//----------------------
- (IBAction)highlightPOIAction:(id)sender {
    captureArray = highlightedPOIsArray;
    [self enableGestureLayer];
}

//----------------------
// Denote a SpaceToken
//----------------------
- (IBAction)spaceTokenPOIAction:(id)sender {
    captureArray = spaceTokenPOIsArray;
    [self enableGestureLayer];
}

- (IBAction)instructionButtonAction:(id)sender {
    textSinkObject = snapShot;
}

- (void)enableGestureLayer{
    self.isAuthoringVisualAidOn = NO;
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    [mapView addSubview:gestureView];
}

- (void)handleSingleTap:(UITapGestureRecognizer *) recognizer{
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    CGPoint location = [recognizer locationInView:mapView];
    CLLocationCoordinate2D coord = [mapView convertPoint:location
                                    toCoordinateFromView:mapView];
    MKCoordinateRegion region = mapView.region;

    //-------------
    // Generate a POI
    //-------------
    POI *poi = [[POI alloc] init];
    poi.latLon = coord;
    poi.coordSpan = region.span;
    poi.isMapAnnotationEnabled = YES;
    
    
    if (captureArray == highlightedPOIsArray){
        //---------------
        // Capture an anchor
        //---------------

        [highlightedPOIsArray addObject:poi];
        
        // Update the label of the button
        NSString *buttonLabel = [NSString stringWithFormat: @"Anchor(%lu)", [highlightedPOIsArray count]];
        [self.highlightedPOIOutlet setTitle:buttonLabel forState:UIControlStateNormal];
        
    }else if (captureArray == spaceTokenPOIsArray){
        //---------------
        // Capture a SpaceToken
        //---------------
        
        [spaceTokenPOIsArray addObject:poi];
        
        // Update the label of the button
        NSString *buttonLabel = [NSString stringWithFormat: @"SpaceToken(%lu)", [spaceTokenPOIsArray count]];
        [self.spaceTokenPOIOutlet setTitle:buttonLabel forState:UIControlStateNormal];
        
        // Create a SpaceToken
        poi.name = @"token";
        SpaceToken* aToken = [self.rootViewController.spaceBar addSpaceTokenFromEntity:poi];
        [self.rootViewController.spaceBar orderButtonArray];
        textSinkObject = aToken;
    }
    
    // Remove the gesture layer
    [gestureView removeFromSuperview];
}

//----------------------
// Reset the interface
//----------------------
- (IBAction)resetAction:(id)sender {
    [self resetInterface];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if ([textSinkObject isKindOfClass:[SpaceToken class]]){
        SpaceToken *aToken = textSinkObject;
        aToken.titleLabel.text = textField.text;
        aToken.spatialEntity.name = textField.text;
    }else if ([textSinkObject isKindOfClass:[Snapshot class]]){
        snapShot.instructions = textField.text;
    }
    
    [textField resignFirstResponder];
    return YES;
}

- (void)resetInterface{
    // Reset segement controls and initialize instant variables
    self.taskTypeOutlet.selectedSegmentIndex = 0;
    [self taskTypeAction:self.taskTypeOutlet];
}

- (void)restartAuthoringFlow{
    // Reinitialize some instance variables
    highlightedPOIsArray = [[NSMutableArray alloc] init];
    spaceTokenPOIsArray = [[NSMutableArray alloc] init];
    targetedPOIsArray = [[NSMutableArray alloc] init];
    
    self.instructionOutlet.text = @"";
    self.captureStartCondOutlet.titleLabel.text = @"Cap-StartCond(0)";
    self.captureEndCondOutlet.titleLabel.text =
    [NSString stringWithFormat:@"Cap-EndCond(%d)", 0];
    self.highlightedPOIOutlet.titleLabel.text = @"Anchor(0)";
    self.spaceTokenPOIOutlet.titleLabel.text = @"SpaceToken(0)";
    
    // Remove all overlays
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    [mapView removeOverlays:mapView.overlays];
 
    // Remove all SpaceTokens
    [self.rootViewController.spaceBar removeAllSpaceTokens];
}


- (IBAction)addAction:(id)sender {
    // Assemble the snapshot
    snapShot.highlightedPOIs = highlightedPOIsArray;
    snapShot.poisForSpaceTokens = spaceTokenPOIsArray;
    
    // Assemble snapshot differently based on Snapshot type
    if ([snapShot isKindOfClass:[SnapshotAnchorPlus class]]){
        // targetedPOIsArray must be empty
        // Fill in the array with the highlighted POI and the SpaceToken
        [targetedPOIsArray addObject:highlightedPOIsArray[0]];
        [targetedPOIsArray addObject:spaceTokenPOIsArray[0]];
    }
    
    // In case the user forgets to press the return key
    snapShot.instructions = self.instructionOutlet.text;
    snapShot.targetedPOIs = targetedPOIsArray;
    
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
    
    snapShot.name = snapshotName;
    
    // Put the snapshot into SnapshotDatabase
    [snapshotDatabase.snapshotArray addObject: snapShot];
    
    // Reset the panel
    [self resetInterface];
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
