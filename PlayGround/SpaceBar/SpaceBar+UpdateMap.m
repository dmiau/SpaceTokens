//
//  SpaceBar+UpdateMap.m
//  SpaceBar
//
//  Created by dmiau on 2/13/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SpaceBar+UpdateMap.h"

@implementation SpaceBar (UpdateMap)

// This is for the SpaceMarks being dragged only
- (void) fillDraggingMapXYs{
    for(SpaceMark* aMark in self.draggingSet) {
        aMark.mapViewXY = aMark.center;
    }
}

- (void) fillMapXYsForSet: (NSSet*) aSet{
    for (POI* aPOI in aSet){
        aPOI.mapViewXY = [self.mapView convertCoordinate:aPOI.latLon
                                           toPointToView:self.mapView];
    }
}

- (void) zoomMapToFitTouchSet{
    // Assume there are at most two touched
    
    if ([self.touchingSet count] == 1){
        SpaceMark *aSpaceMark = [self.touchingSet anyObject];
        aSpaceMark.mapViewXY = CGPointMake(self.mapView.frame.size.width/2, self.mapView.frame.size.height/2);
        [self updateMapToFitPOIs:self.touchingSet];
        
//        // Draw a line
//        [self drawLineFromSpaceMark:aSpaceMark
//                            toPoint:CGPointMake(self.mapView.frame.size.width/2,
//                                                self.mapView.frame.size.height/2)];
        
    }else if ([self.touchingSet count] > 1){
        // Goal: find minMapPointX, maxMapPOintX,
        // minMapPointY, maxMapPointY
        CGFloat minMapPointX, maxMapPointX, minMapPointY, maxMapPointY;
        
        POI *anyPOI = [self.touchingSet anyObject];
        MKMapPoint aMapPoint = MKMapPointForCoordinate(anyPOI.latLon);
        minMapPointX = aMapPoint.x; maxMapPointX = aMapPoint.x;
        minMapPointY = aMapPoint.y; maxMapPointY = aMapPoint.y;
        
        for (POI *aPOI in self.touchingSet){
            MKMapPoint tempMapPoint = MKMapPointForCoordinate(aPOI.latLon);
            minMapPointX = MIN(minMapPointX, tempMapPoint.x);
            maxMapPointX = MAX(maxMapPointX, tempMapPoint.x);
            minMapPointY = MIN(minMapPointY, tempMapPoint.y);
            maxMapPointY = MAX(maxMapPointY, tempMapPoint.y);
            
            NSLog(@"MapPointX: %f, %f", tempMapPoint.x, tempMapPoint.y);
        }
        
        
        // Find out the mid point
        MKMapPoint midPoint = {.x = .5*(maxMapPointX + minMapPointX),
                                .y= .5*(maxMapPointY + minMapPointY)};
        CGFloat height = maxMapPointY - minMapPointY;
        CGFloat width = maxMapPointX - minMapPointX;
        
        // Check the aspect ratio to decide xSpan and ySpan
        CGFloat xSpan, ySpan;
        CGFloat aspectRatio = self.mapView.frame.size.height
        /self.mapView.frame.size.width;
        if (height/width > aspectRatio)
        {
            ySpan = height;
            xSpan = ySpan / aspectRatio;
        }else{
            xSpan = width;
            ySpan = xSpan * aspectRatio;
        }
        
        MKMapRect zoomRect = MKMapRectMake(midPoint.x - xSpan,
                                           midPoint.y - ySpan,
                                           xSpan * 2.3, ySpan*2.3);
        
        [self.mapView setVisibleMapRect:zoomRect animated:NO];
        
        // Clear the touching set
        [self.touchingSet removeAllObjects];
    }
}

//----------------
// update the map based on the constraints specified in POIs
//----------------
- (void) updateMapToFitPOIs: (NSMutableSet*) poiSet{

    // Assume there are at most two POIs
    if ([poiSet count] == 1){
        // The easy case
        POI *aPOI = [poiSet anyObject];
        
        CGFloat diffX = self.mapView.frame.size.width/2 - aPOI.mapViewXY.x;
        CGFloat diffY = self.mapView.frame.size.height/2 - aPOI.mapViewXY.y;
        
        CGPoint targetCGPoint = [self.mapView convertCoordinate:aPOI.latLon toPointToView:self.mapView];
        
        CLLocationCoordinate2D centroid = [self.mapView convertPoint:
            CGPointMake(targetCGPoint.x + diffX, targetCGPoint.y + diffY)
                                              toCoordinateFromView: self.mapView];
        
        [self.mapView setRegion: MKCoordinateRegionMake(centroid,
                                MKCoordinateSpanMake(0.1, 0.1))];
        
    }else if ([poiSet count] == 2){       
        // Use some background map manipulation to figure out the parameters
        MKMapPoint mapPoints[2];
        CGPoint cgPoints[2];
        CLLocationCoordinate2D coords[2];
        
        int i = 0;
        for (POI *aPOI in self.draggingSet){
            coords[i] = aPOI.latLon;
            mapPoints[i] = MKMapPointForCoordinate(aPOI.latLon);
            cgPoints[i] = aPOI.mapViewXY;
            i++;
        }
        
        // Find out the scale factor
        float desiredDistance = sqrtf(powf((cgPoints[0].x - cgPoints[1].x), 2)+
                                      powf((cgPoints[0].y - cgPoints[1].y), 2));
        CGPoint currentCGPoints[2];
        currentCGPoints[0] = [self.mapView convertCoordinate:coords[0] toPointToView:self.mapView];
        currentCGPoints[1] = [self.mapView convertCoordinate:coords[1] toPointToView:self.mapView];
        
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
        CLLocationDirection heading = self.mapView.camera.heading;
        
        self.mapView.camera.heading = 0;
        MKMapRect currentMapRect = self.mapView.visibleMapRect;
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
        [self.mapView setVisibleMapRect:newMapRect];
        self.mapView.camera.heading = heading + rotation/M_PI * 180;

        
        // Correct the translation
        CGFloat targetX = self.mapView.frame.size.width - cgPoints[0].x;
        CGFloat targetY = self.mapView.frame.size.height - cgPoints[0].y;
        
        CLLocationCoordinate2D targetCentroidLatlon = [self.mapView
            convertPoint:CGPointMake(targetX, targetY)
            toCoordinateFromView:self.mapView];
        
        self.mapView.centerCoordinate = targetCentroidLatlon;
    }
}

// Draw a line from pointA to pointB (with timer)
- (void) drawLineFromSpaceMark: (SpaceMark*) aSpaceMark toPoint: (CGPoint) pointA{
    // draw the line
    UIBezierPath *linePath=[UIBezierPath bezierPath];
    [linePath moveToPoint: aSpaceMark.center];
    [linePath addLineToPoint: pointA];
    
    aSpaceMark.lineLayer.path=linePath.CGPath;
    aSpaceMark.lineLayer.fillColor = nil;
    aSpaceMark.lineLayer.opacity = 1.0;
    aSpaceMark.lineLayer.strokeColor = [UIColor blueColor].CGColor;
    [self.mapView.layer addSublayer:aSpaceMark.lineLayer];
}
@end
