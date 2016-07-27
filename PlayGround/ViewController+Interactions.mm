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
    
    if (self.activeRoute){
        CLLocationCoordinate2D coord;
        double orientationInDegree;
                
        [self.activeRoute convertPercentage: percentage
                             toLatLon: coord orientation:orientationInDegree];
        
        [self.mapView setRegion: MKCoordinateRegionMake(coord,
                                                        MKCoordinateSpanMake(0.1, 0.1))];
        
        // set the orientation
//        self.mapView.camera.heading = orientationInDegree;
    }
}

// Two points are touched.
-(void)spaceBarTwoPointsTouchedLow:(float)low high:(float)high{

    if (self.activeRoute){
        // look up the coordinates
        CLLocationCoordinate2D coord1, coord2;
        CGPoint xy1, xy2;
        double orientationInDegree;
        
        //======== 1st point =========
        
        [self.activeRoute convertPercentage: low
                             toLatLon: coord1 orientation:orientationInDegree];
        
        // find the (x, y) coordinates based on the current orientation
        xy1 = [self.mapView convertCoordinate:coord1 toPointToView:self.mapView];
        
        
        //======== 2nd point =========
        [self.activeRoute convertPercentage: high
                             toLatLon: coord2 orientation:orientationInDegree];
        
        xy2 = [self.mapView convertCoordinate:coord2 toPointToView:self.mapView];
        
        
//        // based on the constraints, calculate the map
//        
//        // figure out which one is on top
//        // xy1 should be on top of xy2, if not, swap
//        if (xy1.y < xy2.y){
//            // swap
//            CGPoint tempCGPoint = xy1;
//            CLLocationCoordinate2D tempCoord = coord1;
//            
//            xy1 = xy2; coord1 = coord2;
//            xy2 = tempCGPoint; coord2 = tempCoord;
//        }
        
        // calculate the differences and find the logest axis
        
        CLLocationCoordinate2D coords[2];
        coords[0] = coord1; // 1 is low
        coords[1] = coord2; // 2 is high
        
        CGPoint cgPoints[2];
        cgPoints[0] = CGPointMake(self.mapView.frame.size.width/2,
                                  self.mapView.frame.size.height);
        cgPoints[1] = CGPointMake(self.mapView.frame.size.width/2,0);
        [self.mapView snapTwoCoordinates:coords toTwoXY:cgPoints];
    }
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
             
             // A response is received
             [self initRouteoBject:response];
             [self showRoute:response];
         }
         
         [self updateSpaceBar];
     }];
 
    
    // Add the direction panel
    [self addDirectionPanel];    
}




// Initialize the route object
- (void) initRouteoBject: (MKDirectionsResponse *) response{
    for (MKRoute *route in response.routes)
    {
        self.activeRoute = nil; //reset
        self.activeRoute = [[Route alloc] initWithMKRoute:route];
        self.activeRoute.source = response.source;
        self.activeRoute.destination = response.destination;
        
        // Add annotations to SpaceBar
        [self.spaceBar addAnnotationsFromRoute:self.activeRoute];
        break;
    }
}

-(void)showRoute:(MKDirectionsResponse *)response
{
    for (MKRoute *route in response.routes)
    {
        [self.mapView
         addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
//        // Print out the turn-by-turn instructions
//        for (MKRouteStep *step in route.steps)
//        {
//            NSLog(@"%@", step.instructions);
//        }
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
    [self updateSpaceBar];
}

// Triggers SpaceBar redraw
- (void) updateSpaceBar{
    if (self.activeRoute){
        std::vector<std::pair<float, float>> elevatorResutls =
        [self.activeRoute calculateVisibleSegmentsForMap:self.mapView];
        
        float temp[2];
        temp[0] = elevatorResutls[0].first;
        temp[1] = elevatorResutls.back().second; //TODO: fix this
        // for now I can only display one elevator
        [self.spaceBar updateElevatorFromPercentagePair:temp];
    }
}

- (void) mapTouchBegan: (CLLocationCoordinate2D) coord atXY:(CGPoint)xy{
    // Remove all the touched SpaceTokens
    [self.spaceBar clearAllTouchedTokens];
    
    [self.spaceBar addAnchorForCoordinates:coord atMapXY:xy];
}

- (void) mapTouchMoved: (CLLocationCoordinate2D) coord atXY:(CGPoint)xy{
    
    [self.spaceBar updateAnchorAtMapXY:xy];
}

- (void) mapTouchEnded{
    // Remove all the touched SpaceTokens
    [self.spaceBar clearAllTouchedTokens];
    [self.spaceBar removeAnchor];
}

@end