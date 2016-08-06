//
//  ViewController.m
//  PlayGround
//
//  Created by dmiau on 1/28/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "ViewController.h"
#import "tester.h"
#import "Map/Route.h"
#import "Map/POIDatabase.h"
#import "Map/RouteDatabase.h"
#import "StudyManager/StudyManager.h"

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
    self.myFileManager = [[MyFileManager alloc] init];
    self.myFileManager.directorPartialPath = @"test";
    
    //----------------
    // Initialize Study Manager
    //----------------
    self.studyManager = [[StudyManager alloc] init];
    self.studyManager.studyManagerStatus = OFF;
    
    //----------------
    // Initialize a POI DB
    //----------------
    self.poiDatabase = [[POIDatabase alloc] init];
    [self.poiDatabase reloadPOI];
    
    [self tempSaveDataMethod];
    
    //----------------
    // Initialize a Route DB
    //----------------
    self.routeDatabase = [[RouteDatabase alloc] init];
    [self.routeDatabase reloadRouteDB];
    
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
    
    CLLocationCoordinate2D NYC = CLLocationCoordinate2DMake(40.711801, -74.013120);
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:NYC radius:300]; // radius is measured in meters
    [self.mapView addOverlay:circle];
    
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


//-----------------
// A temporary method to save data into the disk
//-----------------
- (void)tempSaveDataMethod{
    // Need to run on the background thread
    
    //Save the files using the background thread
    //http://stackoverflow.com/questions/12671042/moving-a-function-to-a-background-thread-in-objective-c
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        NSString *dirPath = [self.myFileManager currentFullDirectoryPath];
        NSString *fileFullPath = [dirPath stringByAppendingPathComponent:@"myTest.data"];
        
        // Test file saving capability
        [self.poiDatabase saveDatatoFileWithName:fileFullPath];
        [self.poiDatabase loadFromFile:fileFullPath];
        
        // Perform async operation
        // Call your method/function here
        // Example:
        // NSString *result = [anObject calculateSomething];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
