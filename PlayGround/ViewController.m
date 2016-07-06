//
//  ViewController.m
//  PlayGround
//
//  Created by dmiau on 1/28/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "ViewController.h"
#import "tester.h"


// This is an extension (similar to a category)
@interface ViewController ()

@property NSNumber *touchFlag;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Add a mapView
    self.mapView = [[customMKMapView alloc] initWithFrame:CGRectMake(0, 75,
                                                              self.view.frame.size.width, self.view.frame.size.height - 75)];
    [self.view addSubview:self.mapView];
    [self.mapView setUserInteractionEnabled:YES];
    
    self.mapView.delegate = self;
    
    // Add a SpaceBar
    _spaceBar = [[SpaceBar alloc] initWithMapView:_mapView];    
    self.spaceBar.delegate = self;
    
    // Add several SpaceTokens
    [self.spaceBar addSpaceTokenWithName:@"NY Downtown" LatLon:
     CLLocationCoordinate2DMake(40.712784, -74.005941)];
    
    [self.spaceBar addSpaceTokenWithName:@"Columbia U." LatLon:
     CLLocationCoordinate2DMake(40.807722, -73.964110)];

    [self.spaceBar addSpaceTokenWithName:@"San Francisco" LatLon:
     CLLocationCoordinate2DMake(37.774929, -122.419416)];


    [self.spaceBar addSpaceTokenWithName:@"Boston" LatLon:
     CLLocationCoordinate2DMake(42.360082, -71.058880)];

    [self.spaceBar addSpaceTokenWithName:@"Tokyo" LatLon:
     CLLocationCoordinate2DMake(35.689487, 139.691706)];
    
    
    // Add a direction button for testing
    
    float mapViewWidth = self.mapView.frame.size.width;
    float mapViewHeight = self.mapView.frame.size.height;
    UIButton*  directionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    directionButton.frame = CGRectMake(mapViewWidth*0.1, mapViewHeight*0.9, 60, 20);
    [directionButton setTitle:@"Direction" forState:UIControlStateNormal];
    [directionButton setBackgroundColor:[UIColor grayColor]];
    [directionButton addTarget:self action:@selector(directionButtonAction)
              forControlEvents:UIControlEventTouchDown];
    
    [self.mapView addSubview:directionButton];

//    // Run the test
//    Tester *tester = [[Tester alloc] init];
//    [tester runTests];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
