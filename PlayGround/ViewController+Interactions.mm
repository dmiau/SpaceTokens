//
//  ViewController+Interactions.m
//  SpaceBar
//
//  Created by Daniel on 7/1/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "ViewController+Interactions.h"
#import "Map/RouteDatabase.h"

@implementation ViewController (Interactions)

// The following two are SpaceBar delegate method
- (void)spaceBarOnePointTouched:(float)percentage{
    
    if (self.spaceBar.activeRoute){
        CLLocationCoordinate2D coord;
        double orientationInDegree;
                
        [self.spaceBar.activeRoute convertPercentage: percentage
                             toLatLon: coord orientation:orientationInDegree];
        
        if ([CustomMKMapView validateCoordinate:coord]){
            
            [self.mapView setRegion: MKCoordinateRegionMake(coord,
                                                            MKCoordinateSpanMake(0.1, 0.1))];
        }
    }
}

// Two points are touched.
-(void)spaceBarTwoPointsTouchedLow:(float)low high:(float)high{

    if (self.spaceBar.activeRoute){
        // look up the coordinates
        CLLocationCoordinate2D coord1, coord2;
        CGPoint xy1, xy2;
        double orientationInDegree;
        
        //======== 1st point =========
        
        [self.spaceBar.activeRoute convertPercentage: low
                             toLatLon: coord1 orientation:orientationInDegree];
        
        // find the (x, y) coordinates based on the current orientation
        xy1 = [self.mapView convertCoordinate:coord1 toPointToView:self.mapView];
        
        
        //======== 2nd point =========
        [self.spaceBar.activeRoute convertPercentage: high
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
        coords[0] = coord1; // coord1 is the coordinate on top
        coords[1] = coord2; // coord1 is the coordinate on the bottom
        
        CGPoint cgPoints[2];
        cgPoints[0] =  CGPointMake(self.mapView.frame.size.width/2,0);
        
        cgPoints[1] = CGPointMake(self.mapView.frame.size.width/2,
                                  self.mapView.frame.size.height);
        
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
        
        //----------------------------
        // Move from low to high (from top to bottom)
        // The map is anchored on top
        //----------------------------
        
        // The bottom one (lower value) should be the anchor
        // find the (lat, lon) of the bottom one
        [self.spaceBar.activeRoute convertPercentage:low toLatLon:anchor orientation:orientation1];
        [self.spaceBar.activeRoute convertPercentage:high toLatLon:target orientation:orientation2];
        // Compute the orientation from anchor to target
        CLLocationDirection degree = [CustomMKMapView computeOrientationFromA:target
                                toB:anchor];
        [self.mapView snapOneCoordinate:anchor toXY:CGPointMake(self.mapView.frame.size.width/2, 0) withOrientation:degree animated:NO];
    }else{
        
        //----------------------------
        // Move from high to low
        // The map is anchored on the bottom
        //----------------------------
        [self.spaceBar.activeRoute convertPercentage:high toLatLon:anchor orientation:orientation1];
        [self.spaceBar.activeRoute convertPercentage:low toLatLon:target orientation:orientation2];
        // Compute the orientation from anchor to target
        CLLocationDirection degree = [CustomMKMapView computeOrientationFromA:anchor                                                                          toB:target];
        [self.mapView snapOneCoordinate:anchor toXY:CGPointMake(self.mapView.frame.size.width/2, self.mapView.frame.size.height) withOrientation:degree animated:NO];
    }
}

//-----------------
// Show routes from database
//-----------------
- (void)showRouteFromDatabaseWithName:(NSString*) name
                       zoomToOverview: (BOOL) overviewFlag
{
    
    Route *aRoute = self.routeDatabase.routeDictionary[name];
    if (aRoute){
        [self showRoute:aRoute zoomToOverview: overviewFlag];
    }else{
        NSString *message = [NSString stringWithFormat:@"Route: %@ cannot be found.", name];
        // A route with the name does not exist, throw a warning
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Route not found."
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

//-----------------------
// Display a route on the map
//-----------------------
- (void)showRoute:(Route*) aRoute zoomToOverview: (BOOL) overviewFlag{
    
    // Remove the previous route if there is any
    if (self.spaceBar.activeRoute){
        [self.mapView removeOverlay:
         self.spaceBar.activeRoute.polyline];
        self.spaceBar.activeRoute = nil;
    }

    // Show the new route
    self.spaceBar.activeRoute = aRoute;
    // Remove old annotations and add new ones
    [self.spaceBar removeRouteAnnotations];
    [self.spaceBar addAnnotationsFromRoute:self.spaceBar.activeRoute];
    
    // Only enable SpaceBar after a route is added
    self.spaceBar.spaceBarMode = PATH;
    
    if (overviewFlag){
        // Show the entire route
        [self spaceBarTwoPointsTouchedLow:0 high:1];
        
        // If the mini map is on, zoom the map to fit the entire route
        if (self.miniMapView.superview){            
            [self.miniMapView zoomToFitEntities:
             [NSSet setWithObject: self.spaceBar.activeRoute]];
            // Remove previous routes if any
            [self.miniMapView removeRouteOverlays];

            // REFACTOR
//            [self.miniMapView addOverlay:aRoute.polyline level:MKOverlayLevelAboveRoads];
        }
    }
    
    aRoute.isMapAnnotationEnabled = YES;
}

- (void)removeRoute{
    // Remove the previous route if there is any
    if (self.spaceBar.activeRoute){
        [self.mapView removeOverlay:
         self.spaceBar.activeRoute.polyline];
        self.spaceBar.activeRoute = nil;
    }
    [self.spaceBar removeRouteAnnotations];
    
    // Reset Spacebar
    [self.spaceBar resetSpaceBar];
}


@end
