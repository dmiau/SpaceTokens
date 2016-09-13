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
//    self.rootViewController.mapView.frame = CGRectMake(0, 0, mapWidth, mapHeight);
    
    // Set up the frame of the panel
    self.frame = CGRectMake(0, 0, mapWidth, panelHeight);
    [self.rootViewController.view addSubview:self];
    
    // Add the preference button
    settingsButton.frame = CGRectMake(0, 30, 30, 30);
    [self.rootViewController.view addSubview: settingsButton];
    
    self.isAuthoringVisualAidOn = YES;
    
    // Reset the interface
    [self resetInterface];
}


- (void)removePanel{
    // Remove the settings button
    [settingsButton removeFromSuperview];
    [self removeFromSuperview];
    
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
        float width = mapView.frame.size.width;
        float height = mapView.frame.size.height;
        float diameter = 0.8 * width;
        targetRectBox = CGRectMake(0.1*width, (height - diameter)/2, diameter, diameter);
        
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

- (IBAction)captureStartAction:(id)sender {
    // Save the current map parameters
    MKCoordinateRegion coordinateRegion = [self getTargetCoordinatRegion];
    snapShot.latLon = coordinateRegion.center;
    snapShot.coordSpan = coordinateRegion.span;
    
    // Update the label of the button
    [self.captureStartCondOutlet setTitle:@"Cap-StartCond(1)" forState:UIControlStateNormal];
}

- (IBAction)captureEndAction:(id)sender {
    MKCoordinateRegion coordinateRegion = [self getTargetCoordinatRegion];
    POI *poi = [[POI alloc] init];
    poi.latLon = coordinateRegion.center;
    poi.coordSpan = coordinateRegion.span;
    
    [targetedPOIsArray addObject:poi];
    
    // Update the label of the button
    NSString *buttonLabel = [NSString stringWithFormat: @"Cap-EndCond(%lu)", [targetedPOIsArray count]];
    [self.captureEndCondOutlet setTitle:buttonLabel forState:UIControlStateNormal];
}

- (IBAction)highlightPOIAction:(id)sender {
    MKCoordinateRegion coordinateRegion = [self getTargetCoordinatRegion];
    POI *poi = [[POI alloc] init];
    poi.latLon = coordinateRegion.center;
    poi.coordSpan = coordinateRegion.span;
    
    [highlightedPOIsArray addObject:poi];
    
    // Update the label of the button
    NSString *buttonLabel = [NSString stringWithFormat: @"HighlightedPOI(%lu)", [highlightedPOIsArray count]];
    [self.highlightedPOIOutlet setTitle:buttonLabel forState:UIControlStateNormal];
}

- (IBAction)spaceTokenPOIAction:(id)sender {
    MKCoordinateRegion coordinateRegion = [self getTargetCoordinatRegion];
    POI *poi = [[POI alloc] init];
    poi.latLon = coordinateRegion.center;
    poi.coordSpan = coordinateRegion.span;
    
    [spaceTokenPOIsArray addObject:poi];
    
    // Update the label of the button
    NSString *buttonLabel = [NSString stringWithFormat: @"SpaceToken(%lu)", [spaceTokenPOIsArray count]];
    [self.spaceTokenPOIOutlet setTitle:buttonLabel forState:UIControlStateNormal];
}

- (IBAction)resetAction:(id)sender {
    [self resetInterface];
}

- (IBAction)instructionAction:(id)sender {
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    snapShot.instructions = textField.text;
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
    self.highlightedPOIOutlet.titleLabel.text = @"HighlightedPOI(0)";
    self.spaceTokenPOIOutlet.titleLabel.text = @"SpaceToken(0)";
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
    snapshotDatabase.snapshotDictrionary[snapshotName] = snapShot;
    
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
