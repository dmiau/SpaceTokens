//
//  ShowAuthoringPanel.m
//  NavTools
//
//  Created by Daniel on 11/29/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "ShowAuthoringPanel.h"
#import "SnapshotDatabase.h"
#import "ViewController.h"
#import "CustomMKMapView.h"
#import "EntityDatabase.h"
#import "SnapshotShow.h"
#import "TokenCollectionView.h"

typedef enum {NONANSWER, ANSWER, DISTRACTOR} DROP_POI_TYPE;


@implementation ShowAuthoringPanel{
    DROP_POI_TYPE drop_poi_type;
    UILongPressGestureRecognizer *lpgr;
}

static ShowAuthoringPanel *instance;

+(id)sharedManager {return instance;}

+(id)alloc
{
    return [self sharedManager];
}

+(id)hiddenAlloc
{
    return [super alloc];
}

+(void)initialize
{
    static BOOL initialized = NO;
    if (!initialized){
        initialized = YES;
        instance = [[ShowAuthoringPanel hiddenAlloc] init];
    }
}


#pragma mark --View Init--
- (id)init
{
    if(instance==nil) // allow only to be called once
    {
        self = [super init];
        
        // Initialize instance variables
        drop_poi_type = DISTRACTOR;
        self.snapshot = [[SnapshotShow alloc] init];
        
        // Long press gesture recognizer
        lpgr = [[UILongPressGestureRecognizer alloc]
           initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.delegate = self;
    //        lpgr.delaysTouchesBegan = YES;
    }
    return self;
}

#pragma mark -- Top Panel methods --
- (void)addPanel{
    [super addPanel];
    SnapshotDatabase *snapshotDatabase = [SnapshotDatabase sharedManager];
    [snapshotDatabase loadGameTemplateDatabase];
 
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    [mapView addGestureRecognizer:lpgr];
}


- (void)removePanel{
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    [mapView removeGestureRecognizer:lpgr];
    SnapshotDatabase *snapshotDatabase = [SnapshotDatabase sharedManager];
    [snapshotDatabase saveToCurrentFile];
    
    [super removePanel];
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

//----------------
// Capture the start condition
//----------------
- (IBAction)captureStartAction:(id)sender {
    [super captureInitialMap];
    
    // Update the label of the button
    [self.captureStartCondOutlet setTitle:@"Cap-StartCond(1)" forState:UIControlStateNormal];
}


-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    // Get the map object
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    
    CGPoint location = [gestureRecognizer locationInView:mapView];
    CLLocationCoordinate2D coord = [mapView convertPoint:location
                                    toCoordinateFromView:mapView];
    MKCoordinateRegion region = mapView.region;
    
    // Generate a POI
    POI *poi = [[POI alloc] init];
    poi.latLon = coord;
    poi.coordSpan = region.span;
    poi.isMapAnnotationEnabled = YES;
    
    if (drop_poi_type==ANSWER){
        poi.name = @"answer";
    }else if (drop_poi_type==NONANSWER){
        poi.name = @"non-answer";
    }else if (drop_poi_type==DISTRACTOR){
        poi.name = @"distractor";
    }else{
        [NSException raise:@"Invalid code path" format:@"Unrecognized drop_poi_type"];
    }
    
    // Add the POI to the array
    [self.snapshot.poisForSpaceTokens addObject:poi];
    
    // refresh the token collection view
    [((TokenCollectionView*)[TokenCollectionView sharedManager]) reloadData];
}

//-------------------
// Add a snapshot
//-------------------
- (IBAction)addAction:(id)sender {

    // Get the SnapshotDatabase
    SnapshotDatabase *snapshotDatabase = [SnapshotDatabase sharedManager];
    
    // Generate a name
    NSDateFormatter *formatter;
    NSString        *dateString;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    
    dateString = [formatter stringFromDate:[NSDate date]];
    NSString *prefix = @"Show";
    NSString *snapshotName = [NSString stringWithFormat:@"%@:%@", prefix, dateString];
    
    self.snapshot.name = snapshotName;
    
    // Put the snapshot into SnapshotDatabase
    [snapshotDatabase.snapshotArray addObject: self.snapshot];
    
    // Reset the panel
    [self resetInterface];
}

- (IBAction)resetAction:(id)sender {
    [self resetInterface];
}

- (void)resetInterface{
    
    // Remove all overlays
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    
    // Remove all annotations
    [mapView clear];
    
    // Reset the button
    [self.captureStartCondOutlet setTitle:@"Cap-StartCond(0)" forState:UIControlStateNormal];
    
    self.poiTypeSegmentOutlet.selectedSegmentIndex = 2;
    drop_poi_type = DISTRACTOR;
    
    // Remove all SpaceTokens
    [self.rootViewController.navTools removeAllSpaceTokens];
    [((TokenCollectionView*)[TokenCollectionView sharedManager]) reloadData];
}

- (IBAction)poiTypeSegmentAction:(UISegmentedControl*)segmentControl {
    int selectedSegment = (int)segmentControl.selectedSegmentIndex;
    switch (selectedSegment) {
        case 0:
            drop_poi_type = ANSWER;
            break;
        case 1:
            drop_poi_type = NONANSWER;
            break;
        case 2:
            drop_poi_type = DISTRACTOR;
            break;
        default:
            break;
    }
}

- (IBAction)taskTypeAction:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSString *label = [segmentedControl
                       titleForSegmentAtIndex: [segmentedControl selectedSegmentIndex]];
    MainViewManager *mainViewManager = self.rootViewController.mainViewManager;
    if ([label isEqualToString:@"Place"]){
        // Remove this panel and load another panel
        [mainViewManager showPanelWithType: AUTHORINGPANEL];
    }else if ([label isEqualToString:@"Anchor"]){
        // Remove this panel and load another panel
        [mainViewManager showPanelWithType: AUTHORINGPANEL];
    }else if ([label isEqualToString:@"Show"]){
        // Do nothing
    }else if ([label isEqualToString:@"Constraints"]){
        
    }
}
@end
