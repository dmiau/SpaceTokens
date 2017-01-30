//
//  CustomMKMapView+GMSMapView.m
//  SpaceBar
//
//  Created by Daniel on 1/28/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "CustomMKMapView+GMSMapView.h"
@import GoogleMaps;

@implementation CustomMKMapView (GMSMapView)

-(CGPoint)convertCoordinate:(CLLocationCoordinate2D)coordinate toPointToView:(UIView *)view{

    CGPoint pointInSelfView = [self.projection pointForCoordinate: coordinate];
    return [self convertPoint:pointInSelfView toView:view];
}


-(CLLocationCoordinate2D)convertPoint:(CGPoint)point toCoordinateFromView:(UIView *)view{

    if (view != self){
        [NSException raise:@"Programming error." format:@"the view is not self (convertPoint)"];
    }
    
    return [self.projection coordinateForPoint: point];
}


// Need to implement the following methods
-(void)setRegion:(MKCoordinateRegion)region{
    
    // Build a visible region
    GMSVisibleRegion visibleRegion;
    
    visibleRegion.nearLeft =
    CLLocationCoordinate2DMake(region.center.latitude - region.span.latitudeDelta/2,
                               region.center.longitude - region.span.longitudeDelta/2);
    visibleRegion.nearRight =
    CLLocationCoordinate2DMake(region.center.latitude - region.span.latitudeDelta/2,
                               region.center.longitude + region.span.longitudeDelta/2);
    visibleRegion.farLeft =
    CLLocationCoordinate2DMake(region.center.latitude + region.span.latitudeDelta/2,
                               region.center.longitude - region.span.longitudeDelta/2);
    visibleRegion.farRight =
    CLLocationCoordinate2DMake(region.center.latitude + region.span.latitudeDelta/2,
                               region.center.longitude + region.span.longitudeDelta/2);
    
    GMSCoordinateBounds *coordinateBounds = [[GMSCoordinateBounds alloc] initWithRegion: visibleRegion];
    
    GMSCameraUpdate *cameraUpdate = [GMSCameraUpdate fitBounds: coordinateBounds];
    [self moveCamera: cameraUpdate];
}


-(MKCoordinateRegion)region{
    
    GMSVisibleRegion visibleRegion = self.projection.visibleRegion;
    
    MKCoordinateSpan coordSpan = MKCoordinateSpanMake(
    visibleRegion.nearRight.latitude - visibleRegion.nearLeft.latitude,
    visibleRegion.farRight.longitude - visibleRegion.nearRight.longitude);
    CLLocationCoordinate2D center = self.camera.target;
    
    MKCoordinateRegion output = MKCoordinateRegionMake(center, coordSpan);
    return output;
}

-(void)setVisibleMapRect:(MKMapRect)visibleMapRect{
    [self setRegion: MKCoordinateRegionForMapRect(visibleMapRect)];
}

-(MKMapRect)visibleMapRect{
    return [CustomMKMapView MKMapRectForCoordinateRegion:self.region];
}

- (void)setVisibleMapRect:(MKMapRect)mapRect edgePadding:(UIEdgeInsets)insets animated:(BOOL)animate
{    
    GMSCameraUpdate *cameraUpdate = [GMSCameraUpdate
                        fitBounds: [self coordinateBoundsForMapRect:mapRect]
                                                withEdgeInsets: insets];
    [self moveCamera: cameraUpdate];
}


-(GMSCoordinateBounds*)coordinateBoundsForMapRect:(MKMapRect)mapRect{
    
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    
    // Build a visible region
    GMSVisibleRegion visibleRegion;
    
    visibleRegion.nearLeft =
    CLLocationCoordinate2DMake(region.center.latitude - region.span.latitudeDelta/2,
                               region.center.longitude - region.span.longitudeDelta/2);
    visibleRegion.nearRight =
    CLLocationCoordinate2DMake(region.center.latitude - region.span.latitudeDelta/2,
                               region.center.longitude + region.span.longitudeDelta/2);
    visibleRegion.farLeft =
    CLLocationCoordinate2DMake(region.center.latitude + region.span.latitudeDelta/2,
                               region.center.longitude - region.span.longitudeDelta/2);
    visibleRegion.farRight =
    CLLocationCoordinate2DMake(region.center.latitude + region.span.latitudeDelta/2,
                               region.center.longitude + region.span.longitudeDelta/2);
    
    GMSCoordinateBounds *coordinateBounds = [[GMSCoordinateBounds alloc] initWithRegion: visibleRegion];
    return coordinateBounds;
}

- (void)addOverlay:(id<MKOverlay>)overlay{
    
}

- (void)removeOverlay:(id<MKOverlay>)overlay{
    
}

- (void)addAnnotation:(id<MKAnnotation>)annotation{
    
}

- (void)removeAnnotation:(id<MKAnnotation>)annotation{
    
}

// MARK: Convenient update methods
-(void)updateZoom:(float)newZoom{
    GMSCameraPosition *myNewCamera =
    [GMSCameraPosition
    cameraWithTarget:self.camera.target
     zoom:newZoom
     bearing:self.camera.bearing
    viewingAngle:self.camera.viewingAngle];
    
    self.camera = myNewCamera;
}

-(void)updateBearing:(float)newBearing{
    GMSCameraPosition *myNewCamera =
    [GMSCameraPosition
     cameraWithTarget:self.camera.target
     zoom:self.camera.zoom
     bearing:newBearing
     viewingAngle:self.camera.viewingAngle];
    
    self.camera = myNewCamera;
}

-(void)updateCenterCoordinates:(CLLocationCoordinate2D)newCoord{
    GMSCameraPosition *myNewCamera =
    [GMSCameraPosition
     cameraWithTarget:newCoord
     zoom:self.camera.zoom
     bearing:self.camera.bearing
     viewingAngle:self.camera.viewingAngle];
    
    self.camera = myNewCamera;
}

@end
