//
//  ViewController+Interactions.m
//  SpaceBar
//
//  Created by Daniel on 7/1/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "ViewController+Interactions.h"
#import "Map/Route.h"

@implementation ViewController (Interactions)

// The following two are SpaceBar delegate method
- (void)spaceBarOnePointTouched:(float)percentage{
    
    if (self.route){
        CLLocationCoordinate2D coord;
        double orientationInDegree;
                
        [self.route convertPercentage: percentage
                             toLatLon: coord orientation:orientationInDegree];
        
        [self.mapView setRegion: MKCoordinateRegionMake(coord,
                                                        MKCoordinateSpanMake(0.1, 0.1))];
        
        // set the orientation
//        self.mapView.camera.heading = orientationInDegree;
    }
}


-(void)spaceBarTwoPointsTouched:(float [2])percentagePair{
    
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
        self.route = nil; //reset
        self.route = [[Route alloc] initWithMKRoute:route];
        // only draw the first route
        break;
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

#pragma mark --customMKMapView delegate methods--
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    if (self.route){
        std::vector<std::pair<float, float>> elevatorResutls =
        [self.route calculateVisibleSegmentsForMap:self.mapView];
        
        float temp[2];
        temp[0] = elevatorResutls[0].first;
        temp[1] = elevatorResutls[0].second;
        // for now I can only display one elevator
        [self.spaceBar updateElevatorFromPercentagePair:temp];
    }        
}

@end