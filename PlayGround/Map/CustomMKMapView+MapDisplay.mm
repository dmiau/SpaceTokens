//
//  CustomMKMapView+MapDisplay.m
//  SpaceBar
//
//  Created by dmiau on 7/8/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "CustomMKMapView+MapDisplay.h"
#import "Route.h"

@implementation CustomMKMapView (MapDisplay)

- (void) snapOneCoordinate: (CLLocationCoordinate2D) coord toXY: (CGPoint) viewXY
                  animated: (BOOL) animatedFlag
{
    CGFloat diffX = self.frame.size.width/2 - viewXY.x;
    CGFloat diffY = self.frame.size.height/2 - viewXY.y;
    
    CGPoint targetCGPoint = [self convertCoordinate:coord toPointToView:self];
    
    CLLocationCoordinate2D centroid = [self convertPoint:
                                       CGPointMake(targetCGPoint.x + diffX, targetCGPoint.y + diffY)
                                    toCoordinateFromView: self];
    //    self.mapType = originalType;
    [self setRegion:
     MKCoordinateRegionMake(centroid,MKCoordinateSpanMake(0.01, 0.01))
     animated:animatedFlag];
}

- (void) snapOneCoordinate: (CLLocationCoordinate2D) coord toXY: (CGPoint) viewXY
           withOrientation: (float) orientation animated:(BOOL)animatedFlag
{
    CGFloat diffX = self.frame.size.width/2 - viewXY.x;
    CGFloat diffY = self.frame.size.height/2 - viewXY.y;
    

    CGPoint targetCGPoint = [self convertCoordinate:coord toPointToView:self];
    
    CLLocationCoordinate2D centroid = [self convertPoint:
                                       CGPointMake(targetCGPoint.x + diffX, targetCGPoint.y + diffY)
                                              toCoordinateFromView: self];
    [self setCenterCoordinate:centroid animated:animatedFlag];

    // Set the orientation
    if (orientation){
        self.camera.heading = orientation;
    }
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
    if(CLLocationCoordinate2DIsValid(targetCentroidLatlon)){
        self.centerCoordinate = targetCentroidLatlon;                
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to position the map."
                                                        message:@"Center coordinate is invalid, try again."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}




//---------------------
// Zoom-to-fit
//---------------------
- (void) zoomToFitPOIs: (NSSet<POI*> *) poiSet{
    
    if ([poiSet count] == 0){
        return;
    }else if ([poiSet count] == 1){
        //----------------
        // One POI
        //----------------
        POI *aPOI = [poiSet anyObject];
        MKCoordinateRegion region;
        region.center = aPOI.latLon;
        MKCoordinateSpan span = aPOI.coordSpan;
        span.latitudeDelta = max(0.01, span.latitudeDelta);
        span.longitudeDelta = max(0.01, span.longitudeDelta);
        region.span = span;
        [self setRegion:region animated:NO];
    }else{
        // Goal: find minMapPointX, maxMapPOintX,
        // minMapPointY, maxMapPointY
        CGFloat minMapPointX, maxMapPointX, minMapPointY, maxMapPointY;
        
        POI *aPOI = [poiSet anyObject];
        MKMapPoint aMapPoint = MKMapPointForCoordinate(aPOI.latLon);
        minMapPointX = aMapPoint.x; maxMapPointX = aMapPoint.x;
        minMapPointY = aMapPoint.y; maxMapPointY = aMapPoint.y;
        
        for (POI *aPOI in poiSet){
            MKMapPoint tempMapPoint = MKMapPointForCoordinate(aPOI.latLon);
            minMapPointX = MIN(minMapPointX, tempMapPoint.x);
            maxMapPointX = MAX(maxMapPointX, tempMapPoint.x);
            minMapPointY = MIN(minMapPointY, tempMapPoint.y);
            maxMapPointY = MAX(maxMapPointY, tempMapPoint.y);
        }
        
        
        // Find out the mid point
        MKMapPoint midPoint = {.x = .5*(maxMapPointX + minMapPointX),
            .y= .5*(maxMapPointY + minMapPointY)};
        CGFloat height = maxMapPointY - minMapPointY;
        CGFloat width = maxMapPointX - minMapPointX;
        
        // Check the aspect ratio to decide xSpan and ySpan
        CGFloat xSpan, ySpan;
        CGFloat aspectRatio = self.frame.size.height
        /self.frame.size.width;
        if (height/width > aspectRatio)
        {
            ySpan = height;
            xSpan = ySpan / aspectRatio;
        }else{
            xSpan = width;
            ySpan = xSpan * aspectRatio;
        }
        
        MKMapRect zoomRect = MKMapRectMake(midPoint.x - xSpan * 0.6,
                                           midPoint.y - ySpan * 0.6,
                                           xSpan * 1.2, ySpan*1.2);
        
        [self setVisibleMapRect:zoomRect animated:NO];
    }
}

- (void)zoomToFitRoute:(Route*) aRoute{
    POI *startPOI = [[POI alloc] init];
    POI *endPOI = [[POI alloc] init];
    startPOI.latLon = MKCoordinateForMapPoint
    (MKMapPointMake((*aRoute.mapPointX)[0], (*aRoute.mapPointY)[0]));
    unsigned long length = aRoute.mapPointX->size();
    endPOI.latLon = MKCoordinateForMapPoint
    (MKMapPointMake((*aRoute.mapPointX)[length-1],
                    (*aRoute.mapPointY)[length-1]));
    NSSet *poiSet = [NSSet setWithObjects:startPOI, endPOI, nil];
    [self zoomToFitPOIs:poiSet];
}

@end
