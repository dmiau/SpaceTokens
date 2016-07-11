//
//  customMKMapView+MapDisplay.m
//  SpaceBar
//
//  Created by dmiau on 7/8/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "customMKMapView+MapDisplay.h"

@implementation customMKMapView (MapDisplay)

- (void) snapOneCoordinate: (CLLocationCoordinate2D) coord toXY: (CGPoint) viewXY
{
    
    CGFloat diffX = self.frame.size.width/2 - viewXY.x;
    CGFloat diffY = self.frame.size.height/2 - viewXY.y;
    
    CGPoint targetCGPoint = [self convertCoordinate:coord toPointToView:self];
    
    CLLocationCoordinate2D centroid = [self convertPoint:
        CGPointMake(targetCGPoint.x + diffX, targetCGPoint.y + diffY)
                                        toCoordinateFromView: self];
    
    [self setRegion: MKCoordinateRegionMake(centroid,
                            MKCoordinateSpanMake(0.1, 0.1))];
}


- (void) snapTwoCoordinates: (CLLocationCoordinate2D[2]) coords
                    toTwoXY: (CGPoint[2]) cgPoints{
    
    // Use some background map manipulation to figure out the parameters
    MKMapPoint mapPoints[2];
    for (int i = 1; i < 2; i++){
        mapPoints[i] = MKMapPointForCoordinate(coords[i]);
    }
    
    // Find out the scale factor
    float desiredDistance = sqrtf(powf((cgPoints[0].x - cgPoints[1].x), 2)+
                                  powf((cgPoints[0].y - cgPoints[1].y), 2));
    CGPoint currentCGPoints[2];
    currentCGPoints[0] = [self convertCoordinate:coords[0] toPointToView:self];
    currentCGPoints[1] = [self convertCoordinate:coords[1] toPointToView:self];
    
    float currentDistance = sqrtf(
                                  powf((currentCGPoints[0].x - currentCGPoints[1].x), 2)+
                                  powf((currentCGPoints[0].y - currentCGPoints[1].y), 2));
    double scale = desiredDistance/currentDistance;
    
    // Find out the rotation, use POI_0 as the reference
    double desiredTheta = atan2(-(cgPoints[1].y - cgPoints[0].y),
                                cgPoints[1].x - cgPoints[0].x);
    double currentTheta = atan2(-(currentCGPoints[1].y - currentCGPoints[0].y),
                                currentCGPoints[1].x - currentCGPoints[0].x);
    double rotation = desiredTheta - currentTheta;
    
    
    // Correct the scale first
    
    // Get the current mapRect
    CLLocationDirection heading = self.camera.heading;
    
    self.camera.heading = 0;
    MKMapRect currentMapRect = self.visibleMapRect;
    CGFloat xSpan = currentMapRect.size.width/scale;
    CGFloat ySpan = currentMapRect.size.height/scale;
    MKMapPoint centroidMapPoint = MKMapPointForCoordinate(coords[0]);
    MKMapPoint upperLeftPoint = MKMapPointMake
    (centroidMapPoint.x - xSpan/2, centroidMapPoint.y - ySpan/2);
    
    MKMapRect newMapRect = MKMapRectMake(upperLeftPoint.x,
                                         upperLeftPoint.y,
                                         xSpan,
                                         ySpan);
    // Correct the rotation
    [self setVisibleMapRect:newMapRect];
    self.camera.heading = heading + rotation/M_PI * 180;
    
    
    // Correct the translation
    CGFloat targetX = self.frame.size.width - cgPoints[0].x;
    CGFloat targetY = self.frame.size.height - cgPoints[0].y;
    
    CLLocationCoordinate2D targetCentroidLatlon = [self
                                                   convertPoint:CGPointMake(targetX, targetY)
                                                   toCoordinateFromView:self];
    
    self.centerCoordinate = targetCentroidLatlon;
}

@end