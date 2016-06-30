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
    
    self.mapView.delegate = self;
    
    // Add a SpaceBar
    _spaceBar = [[SpaceBar alloc] initWithMapView:_mapView];    
    
    
    // Add several SpaceMarks
    [self.spaceBar addSpaceMarkWithName:@"NY Downtown" LatLon:
     CLLocationCoordinate2DMake(40.712784, -74.005941)];
    
    [self.spaceBar addSpaceMarkWithName:@"Columbia U." LatLon:
     CLLocationCoordinate2DMake(40.807722, -73.964110)];

    [self.spaceBar addSpaceMarkWithName:@"San Francisco" LatLon:
     CLLocationCoordinate2DMake(37.774929, -122.419416)];


    [self.spaceBar addSpaceMarkWithName:@"Boston" LatLon:
     CLLocationCoordinate2DMake(42.360082, -71.058880)];

    [self.spaceBar addSpaceMarkWithName:@"Tokyo" LatLon:
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


- (void)directionButtonAction {
    NSLog(@"Direction button pressed!");
    
    // Get the direction from New York to Boston
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    
    // Start map item (New York)
    MKPlacemark *startPlacemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(40.712784, -74.005941) addressDictionary:nil];
    MKMapItem *startMapItem = [[MKMapItem alloc] initWithPlacemark:startPlacemark];
    [startMapItem setName:@"New York"];
    request.source = startMapItem;
    
    // End map item (Boston)
    MKPlacemark *endPlacemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(42.360082, -71.058880) addressDictionary:nil];
    MKMapItem *endMapItem = [[MKMapItem alloc] initWithPlacemark:endPlacemark];
    [startMapItem setName:@"Boston"];
    request.destination = endMapItem;
    
    
    request.requestsAlternateRoutes = YES;
    MKDirections *directions =
    [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             // Handle Error
         } else {
             [self showRoute:response];
         }
     }];
        
}

-(void)showRoute:(MKDirectionsResponse *)response
{
    for (MKRoute *route in response.routes)
    {
        [self.mapView
         addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        
        
        // Print out the turn-by-turn instructions
        for (MKRouteStep *step in route.steps)
        {
            NSLog(@"%@", step.instructions);
        }
    }
}


- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    MKPolylineRenderer *renderer =
    [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.lineWidth = 5.0;
    return renderer;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
