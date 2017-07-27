//
//  ViewController+Interactions.m
//  NavTools
//
//  Created by Daniel on 7/1/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "ViewController+Interactions.h"
#import "Route.h"
#import "EntityDatabase.h"
#import "HighlightedEntities.h"

@implementation ViewController (Interactions)

// The following two are SpaceBar delegate method
- (void)spaceBarOnePointTouched:(float)percentage{
    
    if (self.navTools.activeRoute){
        [[HighlightedEntities sharedManager] addEntity:self.navTools.activeRoute];
        CLLocationCoordinate2D coord;
        double orientationInDegree;
        
        if (percentage > 1 || percentage < 0){
            NSLog(@"spaceBarOnePointTouched: %f", percentage);
        }
        
        [self.navTools.activeRoute convertPercentage: percentage
                             toLatLon: coord orientation:orientationInDegree];
        
        if ([CustomMKMapView validateCoordinate:coord]){
            
            [self.mapView setRegion: MKCoordinateRegionMake(coord,
                                                            MKCoordinateSpanMake(0.1, 0.1))];
        }
    }
}

// Two points are touched.
-(void)spaceBarTwoPointsTouchedLow:(float)low high:(float)high{

    if (self.navTools.activeRoute){
        [[HighlightedEntities sharedManager] addEntity:self.navTools.activeRoute];
        // look up the coordinates
        CLLocationCoordinate2D coord1, coord2;
        CGPoint xy1, xy2;
        double orientationInDegree;
        
        //======== 1st point =========
        if (low > 1 || low < 0){
            NSLog(@"spaceBarTwoPointsTouchedLow: (low) %f", low);
        }
        [self.navTools.activeRoute convertPercentage: low
                             toLatLon: coord1 orientation:orientationInDegree];
        
        // find the (x, y) coordinates based on the current orientation
        xy1 = [self.mapView convertCoordinate:coord1 toPointToView:self.mapView];
        
        
        //======== 2nd point =========
        if (high > 1 || high < 0){
            NSLog(@"spaceBarTwoPointsTouchedLow: (high) %f", high);
        }
        [self.navTools.activeRoute convertPercentage: high
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
    [[HighlightedEntities sharedManager] addEntity:self.navTools.activeRoute];
    
    CLLocationCoordinate2D anchor; double orientation1;
    CLLocationCoordinate2D target; double orientation2;
    
    low = ABS(low); // This is necessary because sometimes we could get -0.0 (not sure why)
    high = ABS(high);
    
    
    if (directionFlag){
        
        //----------------------------
        // Move from low to high (from top to bottom)
        // The map is anchored on top
        //----------------------------
        
        // The top one (lower value) should be the anchor
        // find the (lat, lon) of the top one
        if (low > 1 || low < 0){
            NSLog(@"spaceBarElevatorMovedLow: (low) %f", low);
        }
        [self.navTools.activeRoute convertPercentage:low toLatLon:anchor orientation:orientation1];
        
        if (high > 1 || high < 0){
            NSLog(@"spaceBarElevatorMovedLow: (high) %f", high);
        }
        [self.navTools.activeRoute convertPercentage:high toLatLon:target orientation:orientation2];
        
        // Compute the orientation from anchor to target
        CLLocationDirection degree = [CustomMKMapView computeOrientationFromA:target
                                toB:anchor];
        
        // Need to add a margin if high is an end point
        if (high > 0.97){
            // Scroll to the end, the anchor should be anchored on the bottom
            [self.mapView snapOneCoordinate:target toXY:CGPointMake(self.mapView.frame.size.width/2, self.mapView.frame.size.height - 100) withOrientation:degree animated:NO];
        }else{
            
            // Normal case:
            // The map is ahchored on top
            [self.mapView snapOneCoordinate:anchor toXY:CGPointMake(self.mapView.frame.size.width/2, 0) withOrientation:degree animated:NO];
        }

    }else{
        
        //----------------------------
        // Move from high to low
        // The map is anchored on the bottom
        //----------------------------
        if (high > 1 || high < 0){
            NSLog(@"spaceBarElevatorMovedLow: (high) %f", high);
        }
        [self.navTools.activeRoute convertPercentage:high toLatLon:anchor orientation:orientation1];
        
        if (low > 1 || low < 0){
            NSLog(@"spaceBarElevatorMovedLow: (low) %f", low);
        }
        [self.navTools.activeRoute convertPercentage:low toLatLon:target orientation:orientation2];
        // Compute the orientation from anchor to target
        CLLocationDirection degree = [CustomMKMapView computeOrientationFromA:anchor                                                                          toB:target];
        
        
        // Need to add a margin if low is an end point
        if (low < 0.01){
            // Scroll to the end, the anchor should be anchored on the top
            [self.mapView snapOneCoordinate:target toXY:CGPointMake(self.mapView.frame.size.width/2, 100) withOrientation:degree animated:NO];
        }else{
            // Normal case:
            // The map is ahchored on the bottom (when scrolling from the bottom to the top)
            [self.mapView snapOneCoordinate:anchor toXY:CGPointMake(self.mapView.frame.size.width/2, self.mapView.frame.size.height) withOrientation:degree animated:NO];
        }
    }
}

//-----------------------
// Display a route on the map
//-----------------------
- (void)showRoute:(Route*) aRoute zoomToOverview: (BOOL) overviewFlag{
    
    // Remove the previous route if there is any
    if (self.navTools.activeRoute){
        [self.mapView removeOverlay:
         self.navTools.activeRoute.polyline];
        self.navTools.activeRoute = nil;
    }

    // Show the new route
    self.navTools.activeRoute = aRoute;
    // Remove old annotations and add new ones
    [self.navTools.sliderContainer removeRouteAnnotations];
    [self.navTools.sliderContainer addAnnotationsFromRoute:self.navTools.activeRoute];
    
    // Only enable SpaceBar after a route is added
    self.navTools.spaceBarMode = PATH;
    
    if (overviewFlag){
        // Show the entire route
        [self spaceBarTwoPointsTouchedLow:0 high:1];
        
        // If the mini map is on, zoom the map to fit the entire route
        if (self.miniMapView.superview){            
            [self.miniMapView zoomToFitEntities:
             [NSSet setWithObject: self.navTools.activeRoute]];
            // Remove previous routes if any
            [self.miniMapView removeRouteOverlays];

            // REFACTOR
//            [self.miniMapView addOverlay:aRoute.polyline level:MKOverlayLevelAboveRoads];
        }
    }
    
    [[EntityDatabase sharedManager] addEntity:aRoute];
    [[HighlightedEntities sharedManager] clearHighlightedSet];
    [[HighlightedEntities sharedManager] addEntity:aRoute];
}

- (void)removeRoute{
    // Remove the previous route if there is any
    if (self.navTools.activeRoute){
//        [[EntityDatabase sharedManager] removeEntity:self.navTools.activeRoute];        
        self.navTools.activeRoute = nil;
    }
    [self.navTools.sliderContainer removeRouteAnnotations];
    
    // Reset Spacebar
    [self.navTools resetSpaceBar];
}


@end
