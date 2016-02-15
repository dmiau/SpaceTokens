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
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 75,
                                                              self.view.frame.size.width, self.view.frame.size.height - 75)];
    [self.view addSubview:self.mapView];
    [self.mapView setUserInteractionEnabled:YES];
    
    // Add a SpaceBar
    _spaceBar = [[SpaceBar alloc] initWithMapView:_mapView];    
    
    
    // Add several SpaceMarks
    [self.spaceBar addSpaceMarkWithName:@"New York" LatLon:
     CLLocationCoordinate2DMake(40.712784, -74.005941)];

    [self.spaceBar addSpaceMarkWithName:@"Tokyo" LatLon:
     CLLocationCoordinate2DMake(35.689487, 139.691706)];
    
    

//    // Run the test
//    Tester *tester = [[Tester alloc] init];
//    [tester runTests];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
