//
//  ViewController.m
//  PlayGround
//
//  Created by dmiau on 1/28/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "tester.h"
#import "Map/Route.h"
#import "Map/POIDatabase.h"
#import "Map/RouteDatabase.h"
#import "Map/MiniMapView.h"
#import "StudyManager/GameManager.h"
#import "StudyManager/SnapshotDatabase.h"

// This is an extension (similar to a category)
@interface ViewController ()

@property NSNumber *touchFlag;

@end


//-------------------
// Parameters
//-------------------
#define topPanelHeight 150

//-------------------
// ViewController
//-------------------
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    //----------------
    // Initialize File Manager
    //----------------
    self.myFileManager = [MyFileManager sharedManager];
    self.myFileManager.directorPartialPath = @"test";
    
    //----------------
    // Initialize a POI DB
    //----------------
    self.poiDatabase = [POIDatabase sharedManager];
    [self.poiDatabase debugInit];
    
    //----------------
    // Initialize a Route DB
    //----------------
    self.routeDatabase = [[RouteDatabase alloc] init];
    [self.routeDatabase reloadRouteDB];
    
    //----------------
    // Initialize a Snashot DB
    //----------------
    SnapshotDatabase *mySnapshotDatabase = [SnapshotDatabase sharedManager];
    mySnapshotDatabase.name = @"Study";
    [mySnapshotDatabase debugInit];
    
    //----------------
    // Initialize Study Manager
    //----------------
    self.gameManager = [GameManager sharedManager];
    
    //----------------
    // Add a mapView
    //----------------
    self.mapView = [CustomMKMapView sharedManager];
    self.mapView.frame = CGRectMake(0, topPanelHeight,
                                    self.view.frame.size.width, self.view.frame.size.height - topPanelHeight);
    [self.view addSubview:self.mapView];
    [self.mapView setUserInteractionEnabled:YES];
    
    self.mapView.delegate = self;
    
//    [self.mapView setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 60)];
    self.mapView.showsCompass = YES;
    
    CLLocationCoordinate2D NYC = CLLocationCoordinate2DMake(40.711801, -74.013120);
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:NYC radius:300]; // radius is measured in meters
    [self.mapView addOverlay:circle];
    
    
    //----------------
    // Add a mini map
    //----------------
    self.miniMapView = [[MiniMapView alloc] initWithFrame:CGRectMake(0, 0,
                                                                     self.view.frame.size.width/3,
                                                                     self.mapView.frame.size.height/3)];
    [self.miniMapView setUserInteractionEnabled:NO];
    self.miniMapView.showsCompass = NO;
    
    //----------------
    // Add a SpaceBar
    //----------------
    _spaceBar = [[SpaceBar alloc] initWithMapView:_mapView];
    self.spaceBar.spaceBarMode = TOKENONLY;
    self.spaceBar.smallValueOnTopOfBar = false;
    self.spaceBar.delegate = self;
    
    //----------------
    // Initialize MainViewManager
    //----------------
    self.mainViewManager = [[MainViewManager alloc] initWithViewController:self];
    
//    // Run the test
//    Tester *tester = [[Tester alloc] init];
//    [tester runTests];
}


- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
    
    if (self.spaceBar.spaceBarMode == TOKENONLY){
        [self refreshSpaceTokens];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
