//
//  MiniMapView.m
//  SpaceBar
//
//  Created by Daniel on 8/11/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "MiniMapView.h"

@implementation MiniMapView

- (id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.delegate = self;
        self.syncRotation = NO;
        // Add borders
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 1.0f;
        
    }
    return self;
}


- (void) updateBox: (CustomMKMapView*) aMapView{
    // Remove the previous box first
    if (self.boxPolyline){
        [self removeOverlay:self.boxPolyline];
    }
    
    // Get the four corners
    CLLocationCoordinate2D coord = [aMapView convertPoint:CGPointMake(0, 0)
                                         toCoordinateFromView:aMapView];
    CLLocation *coordinates1 =  [[CLLocation alloc] initWithLatitude:coord.latitude
                                                           longitude:coord.longitude];
    
    coord = [aMapView convertPoint:CGPointMake(aMapView.frame.size.width, 0)
                  toCoordinateFromView:aMapView];
    CLLocation *coordinates2 =  [[CLLocation alloc] initWithLatitude:coord.latitude
                                                           longitude:coord.longitude];
    
    coord = [aMapView convertPoint:CGPointMake(aMapView.frame.size.width, aMapView.frame.size.height)
                  toCoordinateFromView:aMapView];
    CLLocation *coordinates3 =  [[CLLocation alloc] initWithLatitude:coord.latitude
                                                           longitude:coord.longitude];
    
    coord = [aMapView convertPoint:CGPointMake(0, aMapView.frame.size.height)
                  toCoordinateFromView:aMapView];
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
    
    self.boxPolyline = [MKPolyline polylineWithCoordinates:coordinates count:numberOfCoordinates];
    [self addOverlay:self.boxPolyline];
}


// Remove non-box overlay
- (void) removeRouteOverlays{
    // REFACTOR
//    for (id <MKOverlay> anOverlay in self.overlays){
//        if (anOverlay != self.boxPolyline){
//            [self removeOverlay:anOverlay];
//        }
//    }
}


- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id < MKOverlay >)overlay
{
    if ([overlay isKindOfClass:[MKCircle class]]){
        //--------------
        // Circle overlay
        //--------------
        MKCircleRenderer *renderer = [[MKCircleRenderer alloc] initWithOverlay:overlay];
        //        renderer.strokeColor = [UIColor redColor];
        renderer.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.4];
        return renderer;
    }else if (overlay == self.boxPolyline){
        //--------------
        // Minimap box overlay
        //--------------
        MKPolylineRenderer *renderer =
        [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        renderer.strokeColor = [UIColor redColor];
        renderer.lineWidth = 2.0;
        return renderer;
    }else{
        //--------------
        // Route overlay
        //--------------
        MKPolylineRenderer *renderer =
        [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        renderer.strokeColor = [UIColor blueColor];
        renderer.lineWidth = 2.0;
        return renderer;
    }
}

@end
