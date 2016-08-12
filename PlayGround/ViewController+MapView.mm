//
//  ViewController+MapView.m
//  SpaceBar
//
//  Created by dmiau on 8/5/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "ViewController+MapView.h"
#import "Map/Route.h"
#import "Map/MiniMapView.h"
#import <MapKit/MapKit.h>

@implementation ViewController (MapView)

#pragma mark --customMKMapView delegate methods--
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    [self updateSpaceBar];
    [self updateMiniMap];
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

- (void) updateMiniMap{
    // Only update mini map if it is viislbe
    if (self.miniMapView.superview){
        
        // Remove all overlays first
        if (self.miniMapView.boxPolyline){
            [self.miniMapView removeOverlay:self.miniMapView.boxPolyline];
        }

        if (self.miniMapView.syncRotation){
            self.miniMapView.camera.heading = self.mapView.camera.heading;
        }
        
        // Get the four corners
        CLLocationCoordinate2D coord = [self.mapView convertPoint:CGPointMake(0, 0)
                                             toCoordinateFromView:self.mapView];
        CLLocation *coordinates1 =  [[CLLocation alloc] initWithLatitude:coord.latitude
                                                               longitude:coord.longitude];
        
        coord = [self.mapView convertPoint:CGPointMake(self.mapView.frame.size.width, 0)
                      toCoordinateFromView:self.mapView];
        CLLocation *coordinates2 =  [[CLLocation alloc] initWithLatitude:coord.latitude
                                                               longitude:coord.longitude];

        coord = [self.mapView convertPoint:CGPointMake(self.mapView.frame.size.width, self.mapView.frame.size.height)
                      toCoordinateFromView:self.mapView];
        CLLocation *coordinates3 =  [[CLLocation alloc] initWithLatitude:coord.latitude
                                                               longitude:coord.longitude];
        
        coord = [self.mapView convertPoint:CGPointMake(0, self.mapView.frame.size.height)
                      toCoordinateFromView:self.mapView];
        CLLocation *coordinates4 =  [[CLLocation alloc] initWithLatitude:coord.latitude
                                                               longitude:coord.longitude];
        
        
        NSMutableArray *locationCoordinates = [[NSMutableArray alloc] initWithObjects:coordinates1,coordinates2,coordinates3,coordinates4,coordinates1, nil];
        
        int numberOfCoordinates = [locationCoordinates count];
        
        CLLocationCoordinate2D coordinates[numberOfCoordinates];
        
        
        for (NSInteger i = 0; i < [locationCoordinates count]; i++) {
            
            CLLocation *location = [locationCoordinates objectAtIndex:i];
            CLLocationCoordinate2D coordinate = location.coordinate;
            
            coordinates[i] = coordinate;
        }
        
        self.miniMapView.boxPolyline = [MKPolyline polylineWithCoordinates:coordinates count:numberOfCoordinates];
        [self.miniMapView addOverlay:self.miniMapView.boxPolyline];
        
    }
}

// Draw a cirlce on map
//- (MKOVerlayRenderer *) mapView:(MKMapView *)map viewForOverlay:(id <MKOverlay>)overlay
//{
//    MKCircleRenderer *circleView = [[MKCircleRenderer alloc] initWithOverlay:overlay];
//    circleView.strokeColor = [UIColor redColor];
//    circleView.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.4];
//    return circleView;
//}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    if ([overlay isKindOfClass:[MKCircle class]]){
        MKCircleRenderer *renderer = [[MKCircleRenderer alloc] initWithOverlay:overlay];
//        renderer.strokeColor = [UIColor redColor];
        renderer.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.4];
        return renderer;
    }else{
        MKPolylineRenderer *renderer =
        [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        renderer.strokeColor = [UIColor blueColor];
        renderer.lineWidth = 5.0;
        return renderer;
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
