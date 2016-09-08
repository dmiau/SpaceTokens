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
#import "Constants.h"

@implementation ViewController (MapView)

#pragma mark --CustomMKMapView delegate methods--
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    [self updateSpaceBar];
    [self updateMiniMap];
    
    // Broadcast a notification about the changing map
    NSNotification *notification = [NSNotification notificationWithName:MapUpdatedNotification
        object:self userInfo:nil];
    [[ NSNotificationCenter defaultCenter] postNotification:notification];
    
    
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
        if (self.miniMapView.syncRotation){
            self.miniMapView.camera.heading = self.mapView.camera.heading;
        }
        [self.miniMapView updateBox:self.mapView];
    }
}

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

- (void) mapTouchBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    // Show the current center and span
    NSLog(@"Center: (%g, %g)",
          self.mapView.centerCoordinate.latitude, self.mapView.centerCoordinate.longitude);
    NSLog(@"Span: (%g, %g)",
          self.mapView.region.span.latitudeDelta, self.mapView.region.span.longitudeDelta);
    
    // Remove all the touched SpaceTokens
    [self.spaceBar clearAllTouchedTokens];    
    [self.spaceBar addAnchorForTouches: touches];
}

- (void) mapTouchMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.spaceBar updateAnchorForTouches: touches];
}

- (void) mapTouchEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    // Remove all the touched SpaceTokens
    [self.spaceBar clearAllTouchedTokens];
    [self.spaceBar removeAnchor];
}


@end
