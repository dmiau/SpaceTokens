//
//  ViewController.m
//  PlayGround
//
//  Created by dmiau on 1/28/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "ViewController.h"
#import "tester.h"
#import "Views/DirectionPanel.h"
#import "Views/DefaultSearchPanel.h"
#import "Map/Route.h"
#import "Map/POIDatabase.h"

//-------------------
// Parameters
//-------------------
#define topPanelHeight 120


// This is an extension (similar to a category)
@interface ViewController ()

@property NSNumber *touchFlag;

@end


//-------------------
// ViewController
//-------------------
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //----------------
    // Refresh the iCloud drive
    //----------------
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *containerURL =
    [fileManager URLForUbiquityContainerIdentifier:nil];
    [fileManager startDownloadingUbiquitousItemAtURL:containerURL error:nil] ;
    
    //----------------
    // Initialize a POI DB
    //----------------
    self.poiDatabase = [[POIDatabase alloc] init];
    [self.poiDatabase reloadPOI];
    
    //----------------
    // Add a mapView
    //----------------
    self.mapView = [[customMKMapView alloc] initWithFrame:CGRectMake(0, topPanelHeight,
                    self.view.frame.size.width, self.view.frame.size.height - topPanelHeight)];
    [self.view addSubview:self.mapView];
    [self.mapView setUserInteractionEnabled:YES];
    
    self.mapView.delegate = self;
    
//    [self.mapView setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 60)];
    self.mapView.showsCompass = NO;
//    self.mapView.mapType = MKMapTypeSatelliteFlyover;
    
    //----------------
    // Add a SpaceBar
    //----------------
    _spaceBar = [[SpaceBar alloc] initWithMapView:_mapView];
    self.spaceBar.spaceBarMode = TOKENONLY;
    self.spaceBar.smallValueOnTopOfBar = false;
    self.spaceBar.delegate = self;
    
    //----------------
    // Initialize the default search panel
    //----------------
    self.defaultSearchPanel = [[DefaultSearchPanel alloc]
                               initWithFrame:
                               CGRectMake(0, 0, self.view.frame.size.width, topPanelHeight)
                               ViewController:self];
    [self.defaultSearchPanel addPanel];

    self.directionPanel = [[DirectionPanel alloc] initWithFrame:
                           CGRectMake(0, 0, self.view.frame.size.width, topPanelHeight)
                           ViewController:self];
    
//    // Run the test
//    Tester *tester = [[Tester alloc] init];
//    [tester runTests];
}


//-----------------
// A temporary method to save data into the disk
//-----------------
- (void)tempSaveDataMethod{
    // Need to run on the background thread
    
    
    // Test file saving capability
    [self.poiDatabase saveDatatoFileWithName:@"myTest.data"];
    [self.poiDatabase loadFromFile:@"myTest.data"];
}


- (void)addDirectionPanel{
    
    if (self.directionPanel){
        // add the panel to the main view if it has been instantiated
        [self.view addSubview:self.directionPanel];
    }else{
        self.directionPanel = [[DirectionPanel alloc] initWithFrame:
                CGRectMake(0, 0, self.view.frame.size.width, topPanelHeight)];
        [self.view addSubview:self.directionPanel];
    }
    
    // remove all
    [self.spaceBar removeAllSpaceTokens];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
