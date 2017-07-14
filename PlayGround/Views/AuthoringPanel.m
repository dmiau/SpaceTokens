//
//  AuthoringPanel.m
//  NavTools
//
//  Created by dmiau on 9/9/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "AuthoringPanel.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "SettingsButton.h"
#import "EntityDatabase.h"
#import "TokenCollection.h"
#import "TokenCollectionView.h"
#import "SnapshotProgress.h"
#import "SnapshotChecking.h"
#import "GameManager.h"

#import "SnapshotDatabase.h"
#import "SnapshotPlace.h"
#import "SnapshotAnchorPlus.h"

@implementation AuthoringPanel{
    // Adding an UIVeiw to capture gestures
    UIView *gestureView;
    NSMutableArray *captureArray;
}

static AuthoringPanel *instance;

+(id)sharedManager {return instance;}

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
        self = [super init];
        
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
    [super addPanel];
    // Set up the gestureView to capture gestures
    float mapWidth = self.rootViewController.mapView.frame.size.width;
    float mapHeight = self.rootViewController.mapView.frame.size.height;
    gestureView.frame = CGRectMake(0, 0, mapWidth, mapHeight);
    [gestureView setBackgroundColor:[UIColor blackColor]];
    gestureView.alpha = 0.4;
}


- (void)removePanel{
    // Remove the gesture layer
    [gestureView removeFromSuperview];
    [super removePanel];
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
    
    // REFACTOR
    MKCoordinateRegion coordinateRegion;
//    = [mapView convertRect:targetRectBox
//                                              toRegionFromView:mapView];
    return coordinateRegion;
}

#pragma mark --Authoring Actions--

- (IBAction)taskTypeAction:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSString *label = [segmentedControl
                       titleForSegmentAtIndex: [segmentedControl selectedSegmentIndex]];
    [self restartAuthoringFlow];
    if ([label isEqualToString:@"Place"]){
        self.snapshot = [[SnapshotPlace alloc] init];
        // Enable some of the buttons
        [self.captureEndCondOutlet setEnabled:YES];
        [self.highlightedPOIOutlet setEnabled:NO];
    }else if ([label isEqualToString:@"Anchor"]){
        self.snapshot = [[SnapshotAnchorPlus alloc] init];
        // Disable some of the buttons
        [self.captureEndCondOutlet setEnabled:NO];
        [self.highlightedPOIOutlet setEnabled:YES];
    }else if ([label isEqualToString:@"Show"]){
        // Remove this panel and load another panel
        MainViewManager *mainViewManager = self.rootViewController.mainViewManager;
        [mainViewManager showPanelWithType: SHOWAUTHORINGPANEL];
    }else if ([label isEqualToString:@"Constraints"]){

    }
}


//----------------
// Capture the start condition
//----------------
- (IBAction)captureStartAction:(id)sender {
    [super captureInitialMap];
    
    // Update the label of the button
    [self.captureStartCondOutlet setTitle:@"Cap-StartCond(1)" forState:UIControlStateNormal];
}


//----------------
// Capture the end condition
//----------------
- (IBAction)captureEndAction:(id)sender {

    [super captureEndingMap];
    
    // Update the label of the button
    NSString *buttonLabel = [NSString stringWithFormat: @"Cap-EndCond(%lu)", [self.snapshot.targetedPOIs count]];
    [self.captureEndCondOutlet setTitle:buttonLabel forState:UIControlStateNormal];
}

//----------------------
// Denote an anchor
//----------------------
- (IBAction)highlightPOIAction:(id)sender {
    captureArray = self.snapshot.highlightedPOIs;
    [self enableGestureLayer];
}

//----------------------
// Denote a SpaceToken
//----------------------
- (IBAction)spaceTokenPOIAction:(id)sender {
    captureArray = self.snapshot.poisForSpaceTokens;
    [self enableGestureLayer];
}

- (IBAction)instructionButtonAction:(id)sender {
    textSinkObject = self.snapshot;
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
    
    
    if (captureArray == self.snapshot.highlightedPOIs){
        //---------------
        // Capture an anchor
        //---------------

        [self.snapshot.highlightedPOIs addObject:poi];
        
        // Update the label of the button
        NSString *buttonLabel = [NSString stringWithFormat: @"Anchor(%lu)", [self.snapshot.highlightedPOIs count]];
        [self.highlightedPOIOutlet setTitle:buttonLabel forState:UIControlStateNormal];
        
    }else if (captureArray == self.snapshot.poisForSpaceTokens){
        //---------------
        // Capture a SpaceToken
        //---------------
        
        [self.snapshot.poisForSpaceTokens addObject:poi];
        
        // Update the label of the button
        NSString *buttonLabel = [NSString stringWithFormat: @"SpaceToken(%lu)", [self.snapshot.poisForSpaceTokens count]];
        [self.spaceTokenPOIOutlet setTitle:buttonLabel forState:UIControlStateNormal];
        
        // Put the entity into EntityDatabase
        poi.name = @"token";
        
        [[EntityDatabase sharedManager] addEntity:poi];
        // refresh the token panel
        [((TokenCollectionView*)[TokenCollectionView sharedManager]) reloadData];
        
        textSinkObject = [[TokenCollectionView sharedManager] findSpaceTokenFromEntity:poi];
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
        self.snapshot.instructions = textField.text;
    }
    
    [textField resignFirstResponder];
    return YES;
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
    NSString *prefix = SnapshotTypeToPrefix(self.snapshot);
    NSString *snapshotName = [NSString stringWithFormat:@"%@:%@", prefix, dateString];
    
    self.snapshot.name = snapshotName;
    
    // Put the snapshot into SnapshotDatabase
    [snapshotDatabase.snapshotArray addObject: self.snapshot];
    
    // Reset the panel
    [self resetInterface];
}


#pragma mark -- reset and reinitialize the interface --
- (void)resetInterface{
    // Reset segement controls and initialize instant variables
    self.taskTypeOutlet.selectedSegmentIndex = 0;
    [self taskTypeAction:self.taskTypeOutlet];
}

- (void)restartAuthoringFlow{
    
    self.instructionOutlet.text = @"";
    self.captureStartCondOutlet.titleLabel.text = @"Cap-StartCond(0)";
    self.captureEndCondOutlet.titleLabel.text =
    [NSString stringWithFormat:@"Cap-EndCond(%d)", 0];
    self.highlightedPOIOutlet.titleLabel.text = @"Anchor(0)";
    self.spaceTokenPOIOutlet.titleLabel.text = @"SpaceToken(0)";
    
    // Remove all overlays
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    [mapView clear];
    
    // Remove all SpaceTokens
    [self.rootViewController.navTools removeAllSpaceTokens];
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
