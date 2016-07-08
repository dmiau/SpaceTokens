//
//  SpaceBar+UpdateMap.m
//  SpaceBar
//
//  Created by dmiau on 2/13/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SpaceBar+UpdateMap.h"

@implementation SpaceBar (UpdateMap)

// This is for the SpaceTokens being dragged only
// Note that a draggingSet could contain POIs (e.g., ANCHOR) or SpaceTokens
// fillDraggingMapXYs should only apply to SpaceTokens
- (void) fillDraggingMapXYs{
    for(id anItem in self.draggingSet) {
        if ([anItem isKindOfClass:[SpaceToken class]]){
            SpaceToken* aMark = (SpaceToken*)anItem;
            aMark.mapViewXY = aMark.center;
        }
    }
}

// This method finds the (x, y) corrdinates corresponding to the (lat, lon)
// of each POI, and fills that information into each POI.
// This is useful for POI sorting on SpaceBar
- (void) fillMapXYsForSet: (NSSet*) aSet{
    for (POI* aPOI in aSet){
        aPOI.mapViewXY = [self.mapView convertCoordinate:aPOI.latLon
                                           toPointToView:self.mapView];
    }
}

//----------------
// zoom-to-fit
//----------------
- (void) zoomMapToFitTouchSet{
    // Assume there are at most two touched
    
    if ([self.touchingSet count] == 1){
        
        // this is to support anchor+X
        // one anchor + one touched SpaceToken
        if (self.anchor)
        {
            SpaceToken *aSpaceToken = [self.touchingSet anyObject];
            aSpaceToken.mapViewXY =
            CGPointMake(aSpaceToken.center.x - aSpaceToken.frame.size.width *0.7, aSpaceToken.center.y);
            
            NSMutableSet* aSet = [[NSMutableSet alloc] init];
            [aSet addObject:aSpaceToken];
            [aSet addObject:self.anchor];
            [self snapToTwoPOIs:  aSet];
        }else{
            SpaceToken *aSpaceToken = [self.touchingSet anyObject];
            aSpaceToken.mapViewXY = CGPointMake(self.mapView.frame.size.width/2, self.mapView.frame.size.height/2);
            [self updateMapToFitPOIPreferences:self.touchingSet];
        }
                
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
// zoom-to-preference
//----------------
- (void) updateMapToFitPOIPreferences: (NSMutableSet*) poiSet{
    
    // this is to support anchor+X
    // one anchor + one dragging SpaceToken
    if ([self.draggingSet count] == 1
        && [self.draggingSet anyObject] != self.anchor
        && self.anchor)
    {
        [self.draggingSet addObject:self.anchor];
    }
    
    // Assume there are at most two POIs
    if ([poiSet count] == 1 &&
        [poiSet anyObject] != self.anchor)
    {
        // The easy case
        POI *aPOI = [poiSet anyObject];
        [self snapToOnePOI:aPOI];
    }else if ([poiSet count] == 2){       
        [self snapToTwoPOIs:  poiSet];
    }
}

// this method makes the map snap to two POIs
- (void) snapToOnePOI: (POI*) aPOI {
    CGFloat diffX = self.mapView.frame.size.width/2 - aPOI.mapViewXY.x;
    CGFloat diffY = self.mapView.frame.size.height/2 - aPOI.mapViewXY.y;
    
    CGPoint targetCGPoint = [self.mapView convertCoordinate:aPOI.latLon toPointToView:self.mapView];
    
    CLLocationCoordinate2D centroid = [self.mapView convertPoint:
                                       CGPointMake(targetCGPoint.x + diffX, targetCGPoint.y + diffY)
                                            toCoordinateFromView: self.mapView];
    
    [self.mapView setRegion: MKCoordinateRegionMake(centroid,
                                                    MKCoordinateSpanMake(0.1, 0.1))];
}


// this method makes the map snap to two POIs
- (void) snapToTwoPOIs: (NSSet*) poiSet{
    // Use some background map manipulation to figure out the parameters
    MKMapPoint mapPoints[2];
    CGPoint cgPoints[2];
    CLLocationCoordinate2D coords[2];
    
    int i = 0;
    for (POI *aPOI in poiSet){
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


// Draw a line from pointA to pointB (with timer)
- (void) drawLineFromSpaceToken: (SpaceToken*) aSpaceToken toPoint: (CGPoint) pointA{
    // draw the line
    UIBezierPath *linePath=[UIBezierPath bezierPath];
    [linePath moveToPoint: aSpaceToken.center];
    [linePath addLineToPoint: pointA];
    
    aSpaceToken.lineLayer.path=linePath.CGPath;
    aSpaceToken.lineLayer.fillColor = nil;
    aSpaceToken.lineLayer.opacity = 1.0;
    aSpaceToken.lineLayer.strokeColor = [UIColor blueColor].CGColor;
    [self.mapView.layer addSublayer:aSpaceToken.lineLayer];
}
@end
