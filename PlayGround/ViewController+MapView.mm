//
//  ViewController+MapView.m
//  NavTools
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
#import "HighlightedEntities.h"

@implementation ViewController (MapView)

#pragma mark --CustomMKMapView delegate methods--
-(void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture{
//    self.mapView.isMapStable = NO;
}


// This is called when the map is changed
-(void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position{
    self.mapView.isMapStable = NO;
    [self updateSystem];
}



// This is called when the map becomes idle
-(void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position{    
    self.mapView.isMapStable = YES;
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
    if (self.navTools.activeRoute){
        std::vector<std::pair<float, float>> elevatorResutls =
        [self.navTools.activeRoute calculateVisibleSegmentsForMap:self.mapView];
        
        float temp[2];
        temp[0] = elevatorResutls[0].first;
        temp[1] = elevatorResutls.back().second; //TODO: fix this
        // for now I can only display one elevator
        [self.navTools.sliderContainer updateElevatorFromPercentagePair:temp];
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


- (void) mapTouchBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    
    if ([self.navTools.touchingSet count] > 0){
        // We want to keep the highlight a bit longer after the selected SpaceToken is deselected.
        [HighlightedEntities sharedManager].skipClearingHighlightRequestCount = 1;
    }
    // Remove all the touched SpaceTokens
    [self.navTools clearAllTouchedTokens];

    // Put the touch into a watch mechanism
    [self.navTools addAnchorForTouches: touches];
    
    // Reset the map information dialog
    [[CustomMKMapView sharedManager] removeInformationView];
}

- (void) mapTouchMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    [self.navTools updateAnchorForTouches: touches];
}

- (void) mapTouchEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    // Remove all the touched SpaceTokens
    [self.navTools clearAllTouchedTokens];
    
    [self.navTools removeAnchorForTouches:touches];
}

@end
