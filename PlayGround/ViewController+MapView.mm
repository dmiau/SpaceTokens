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
#import "CustomPointAnnotation.h"

@implementation ViewController (MapView)

#pragma mark --CustomMKMapView delegate methods--
// This is called when the map is changed
-(void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position{
    [self updateSystem];
}

// This is called when the map becomes idle
-(void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position{    

    // Timer action to disable the highlight
    NSTimer *delayUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.05
                                                       target:self
                                                     selector:@selector(updateSystem)
                                                     userInfo:nil repeats:NO];
    
}

- (void)updateSystem{
    [self updateSpaceBar];
    [self updateMiniMap];
    
    // Broadcast a notification about the changing map
    NSNotification *notification = [NSNotification notificationWithName:MapUpdatedNotification
                                                                 object:self userInfo:nil];
    [[ NSNotificationCenter defaultCenter] postNotification:notification];
}


// Triggers SpaceBar redraw
- (void) updateSpaceBar{
    if (self.spaceBar.activeRoute){
        std::vector<std::pair<float, float>> elevatorResutls =
        [self.spaceBar.activeRoute calculateVisibleSegmentsForMap:self.mapView];
        
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
            
            GMSCameraPosition *myCamera = self.miniMapView.camera;
            GMSCameraPosition *myNewCamera = [GMSCameraPosition
                                              cameraWithLatitude:myCamera.target.latitude
                                              longitude:myCamera.target.longitude
                                              zoom:myCamera.zoom
                                              bearing:self.mapView.camera.bearing
                                              viewingAngle:myCamera.viewingAngle];
            self.miniMapView.camera = myNewCamera;
        }
        [self.miniMapView updateBox:self.mapView];
    }
}

// REFACTOR
//- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
//{
//    MKOverlayRenderer* renderer =  [self.mapView rendererForOverlay:overlay];
//    return renderer;
//}


- (void) mapTouchBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    // Remove all the touched SpaceTokens
    [self.spaceBar clearAllTouchedTokens];
    

    // Put the touch into a watch mechanism
    [self.spaceBar addAnchorForTouches: touches];
}

- (void) mapTouchMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    [self.spaceBar updateAnchorForTouches: touches];
}

- (void) mapTouchEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    // Remove all the touched SpaceTokens
    [self.spaceBar clearAllTouchedTokens];
    
    [self.spaceBar removeAnchorForTouches:touches];
}

@end
