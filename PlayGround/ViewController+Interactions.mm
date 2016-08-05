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

// The elevator is moved!
- (void)spaceBarElevatorMovedLow:(float) low
                            high: (float) high
                   fromLowToHigh:(bool)directionFlag
{    
    CLLocationCoordinate2D anchor; double orientation1;
    CLLocationCoordinate2D target; double orientation2;
    if (directionFlag){
        // Move from low to high
        
        // The bottom one (lower value) should be the anchor
        // find the (lat, lon) of the bottom one
        [self.activeRoute convertPercentage:low toLatLon:anchor orientation:orientation1];
        [self.activeRoute convertPercentage:high toLatLon:target orientation:orientation2];
        // Compute the orientation from anchor to target
        CLLocationDirection degree = [self.mapView computeOrientationFromA:anchor
                                                                       toB:target];
        [self.mapView snapOneCoordinate:anchor toXY:CGPointMake(self.mapView.frame.size.width/2, self.mapView.frame.size.height) withOrientation:degree];
    }else{
       // Move from high to low
        [self.activeRoute convertPercentage:high toLatLon:anchor orientation:orientation1];
        [self.activeRoute convertPercentage:low toLatLon:target orientation:orientation2];
        // Compute the orientation from anchor to target
        CLLocationDirection degree = [self.mapView computeOrientationFromA:target
                                                                       toB:anchor];
        [self.mapView snapOneCoordinate:anchor toXY:CGPointMake(self.mapView.frame.size.width/2, 0) withOrientation:degree];
    }

    
}

- (void)directionButtonAction {
    NSLog(@"Direction button pressed!");
    
    // Check if a route has been loaded
    
    
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
    [endMapItem setName:@"Boston"];
    request.destination = endMapItem;
    
    
    request.requestsAlternateRoutes = YES;
    MKDirections *directions =
    [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             // Handle Error
         } else {
             NSLog(@"Direction response received!");
             MKRoute *tempRoute = response.routes[0];
             Route *myRoute =
             [[Route alloc] initWithMKRoute:tempRoute
                                     Source:response.source Destination:response.destination];
             [self showRoute:myRoute];
         }
//         [self updateSpaceBar];
     }];
    // Add the direction panel
    [self.mainViewManager showPanelWithType:DIRECTION];
}

//-----------------
// This method does the following things
//-----------------
- (void)showRoute:(Route*) aRoute{
    
    // Remove the previous route if there is any
    if (self.activeRoute){
        [self.mapView removeOverlay:
         self.activeRoute.route.polyline];
        self.activeRoute = nil;
    }

    // Show the new route
    self.activeRoute = aRoute;
    // Remove old annotations and add new ones
    [self.spaceBar removeRouteAnnotations];
    [self.spaceBar addAnnotationsFromRoute:self.activeRoute];
    
    // Show the entire route
    [self spaceBarTwoPointsTouchedLow:0 high:1];
    
    // Only enable SpaceBar after a route is added
    self.spaceBar.spaceBarMode = PATH;
    
    [self.mapView addOverlay:aRoute.route.polyline level:MKOverlayLevelAboveRoads];
}

@end