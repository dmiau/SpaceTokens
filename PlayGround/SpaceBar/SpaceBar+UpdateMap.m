//
//  SpaceBar+UpdateMap.m
//  SpaceBar
//
//  Created by dmiau on 2/13/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SpaceBar+UpdateMap.h"
#import "POI.h"

@implementation SpaceBar (UpdateMap)

// fillDraggingMapXYs should only apply to SpaceTokens
// Note that a draggingSet could contain ANCHORs or SpaceTokens

- (void) fillDraggingMapXYs{
    for(SpaceToken* anItem in self.draggingSet) {
        if (anItem.appearanceType != ANCHOR_VISIBLE
            || anItem.appearanceType != ANCHOR_INVISIBLE)
        {
            SpaceToken* aMark = (SpaceToken*)anItem;
            aMark.mapViewXY = aMark.center;
        }
    }
}

//----------------
// zoom-to-fit
//----------------
- (void) zoomMapToFitTouchSet{
    
    
    SpaceToken *oneAnchor;
    
    if ([self.anchorSet count]==1){
        oneAnchor = [self.anchorSet anyObject];
//        oneAnchor.isConstraintLineOn = YES;
    }else if ([self.draggingSet count]==1){
        oneAnchor = [self.draggingSet anyObject];
//        oneAnchor.isConstraintLineOn = YES;
    }
    
    
    if (oneAnchor){
        //--------------
        // One anchor
        //--------------
        // Show the anchor and one desired location
        
        // Turn on the debug visual
        [oneAnchor configureAppearanceForType:ANCHOR_VISIBLE];
        oneAnchor.spatialEntity.annotation.pointType = DEFAULT_MARKER;
        
        // Snap to the anchor first
        // So zoom-to-fit is dynamically updated when the anchor is moved
        [self.mapView snapOneCoordinate: oneAnchor.spatialEntity.latLon
                                   toXY: oneAnchor.mapViewXY
                        withOrientation:self.mapView.camera.bearing animated:NO];
        
        
        
        //----------------------------------
        // need to check visibility before zoom-to-fit
        //----------------------------------
        BOOL allVisible = YES; // Assume all are visible
    
        for (SpaceToken *aToken in self.touchingSet){
            allVisible = allVisible & [aToken.spatialEntity checkVisibilityOnMap:[CustomMKMapView sharedManager]];
        }
    
        if (allVisible && self.mapView.camera.zoom > 10 ){
            return;
        }
        
        //----------------------------------
        // some of the elements are invisible, need to compute a new bounds
        //----------------------------------
        
        GMSCoordinateBounds *bounds = [self computerGMSBoundsForTokenSets:self.touchingSet andAnchor:oneAnchor];
        GMSCameraUpdate *cameraUpdate = [GMSCameraUpdate
                                         fitBounds: bounds
                                         withEdgeInsets: self.mapView.edgeInsets];
        [self.mapView moveCamera: cameraUpdate];
        
    }else{
        //--------------
        // Zero anchor, or more than one anchor
        //--------------
        
        // Put POIs in touchingSet into a poiSet
        NSMutableSet <POI*>* poiSet =
        [[NSMutableSet alloc] init];
        for (SpaceToken* aToken in self.touchingSet){
            [poiSet addObject: aToken.spatialEntity];
        }
        
        // Put POIs in anchorSet into a poiSet
        for (SpaceToken *aToken in self.anchorSet){
            [poiSet addObject:aToken.spatialEntity];
            
            [aToken configureAppearanceForType:ANCHOR_VISIBLE];
            aToken.spatialEntity.annotation.pointType = DEFAULT_MARKER;
            // Draw the constraint line
            aToken.isConstraintLineOn = YES;
        }
        
        // Zoom to fit
        [self.mapView zoomToFitEntities:poiSet];
    }
}

//----------------
// zoom-to-preference
//----------------
- (void) updateMapToFitPOIPreferences: (NSMutableSet*) tokenSet{
    
    BOOL isAnchorInDraggingSet = NO;
    if ([self.anchorSet count]>0){
        NSMutableSet *intersectSet = [NSMutableSet setWithSet:tokenSet];
        [intersectSet intersectSet:self.anchorSet];
        if ([intersectSet count] > 0){
            isAnchorInDraggingSet = YES;
        }
    }
    
    // this is to support anchor+X
    // one anchor + one dragging SpaceToken
    if ([tokenSet count] == 1
        && !isAnchorInDraggingSet
        && [self.anchorSet count]==1)
    {
        SpaceToken *anchor = [self.anchorSet anyObject];
        [anchor configureAppearanceForType:ANCHOR_VISIBLE];
        anchor.spatialEntity.annotation.pointType = DEFAULT_MARKER;
        [self.draggingSet addObject:anchor];
    }
    
    // Assume there are at most two POIs
    if ([tokenSet count] == 1)
    {
        //----------------------
        // Snap to one SpaceToken
        //----------------------
        SpaceToken *aToken = [tokenSet anyObject];
        [self.mapView snapOneCoordinate: aToken.spatialEntity.latLon toXY: aToken.mapViewXY
                        withOrientation:self.mapView.camera.bearing animated:NO];
    }else if ([tokenSet count] == 2){
        
        //----------------------
        // Snap to two SpaceTokens
        //----------------------
        [self snapToTwoTokens: tokenSet];
    }
}


//------------------
// Compute the bounding box that includes an anchor and tokens (Google Maps version)
//------------------
- (GMSCoordinateBounds*)computerGMSBoundsForTokenSets: (NSSet*)tokenSet
                                    andAnchor: (SpaceToken*) anchor
{

    // Compute the bounding POIs
    CGFloat minCGPointX, maxCGPointX, minCGPointY, maxCGPointY;
    
    // To initialize the search
    SpaceToken *aToken = [tokenSet anyObject];
    CGPoint aCGPoint = [self.mapView convertCoordinate: aToken.spatialEntity.latLon
                                         toPointToView: self.mapView];
    minCGPointX = aCGPoint.x; maxCGPointX = aCGPoint.x;
    minCGPointY = aCGPoint.y; maxCGPointY = aCGPoint.y;
    
    for (SpaceToken *aToken in tokenSet){
        CGPoint tempMapPoint = [self.mapView convertCoordinate: aToken.spatialEntity.latLon
                                                 toPointToView: self.mapView];
        minCGPointX = MIN(minCGPointX, tempMapPoint.x);
        maxCGPointX = MAX(maxCGPointX, tempMapPoint.x);
        minCGPointY = MIN(minCGPointY, tempMapPoint.y);
        maxCGPointY = MAX(maxCGPointY, tempMapPoint.y);
    }
    
    CGPoint anchorCGPoint = anchor.mapViewXY;
    
    // Need to figure out the arrangement of the points
    double leftEdge, rightEdge, topEdge, bottomEdge;
    leftEdge = self.mapView.edgeInsets.left;
    rightEdge = self.mapView.frame.size.width - self.mapView.edgeInsets.right;
    topEdge = self.mapView.edgeInsets.top;
    bottomEdge = self.mapView.frame.size.height - self.mapView.edgeInsets.bottom;
    
    // Goal: find targetedMinX, targetedMaxX, targetedMinY, targetedMaxY
    double targetedMinX, targetedMaxX, targetedMinY, targetedMaxY;
    
    // find the boubdary in the x direction
    findTargetedMinMax(leftEdge, anchorCGPoint.x, rightEdge
                       , minCGPointX, maxCGPointX,
                       &targetedMinX, &targetedMaxX);
    
    // find the boubdary in the y direction
    findTargetedMinMax(topEdge, anchorCGPoint.y, bottomEdge
                       , minCGPointY, maxCGPointY,
                       &targetedMinY, &targetedMaxY);
    
    // Need to further correct the aspect ratio
    double xDiff = targetedMaxX - targetedMinX;
    double yDiff = targetedMaxY - targetedMinY;
    
    double mapWidth = self.mapView.frame.size.width -
    self.mapView.edgeInsets.left - self.mapView.edgeInsets.right;
    double mapHeight = self.mapView.frame.size.height -
    self.mapView.edgeInsets.top - self.mapView.edgeInsets.bottom;
    
    if (yDiff/xDiff > mapHeight/mapWidth)
    {
        double scale = yDiff / mapHeight * mapWidth / xDiff;
        targetedMinX = anchorCGPoint.x - scale * (anchorCGPoint.x - targetedMinX);
        targetedMaxX = scale * (targetedMaxX - anchorCGPoint.x) + anchorCGPoint.x;
    }else{
        double scale = xDiff / mapWidth * mapHeight / yDiff;
        targetedMinY = anchorCGPoint.y - scale * (anchorCGPoint.y - targetedMinY);
        targetedMaxY = scale * (targetedMaxY - anchorCGPoint.y) + anchorCGPoint.y;
    }
    
    
//    // Generate MapRect (first need to convert from CGPoint to MapPoints)
//    MKMapPoint topLeft =
//    MKMapPointForCoordinate(
//                            [self.mapView convertPoint:CGPointMake(targetedMinX, targetedMinY)
//                                  toCoordinateFromView: self.mapView]);
//    
//    MKMapPoint bottomRight =
//    MKMapPointForCoordinate(
//                            [self.mapView convertPoint:CGPointMake(targetedMaxX, targetedMaxY)
//                                  toCoordinateFromView: self.mapView]);
//    
//    MKMapRect outMapRect = MKMapRectMake(topLeft.x, topLeft.y,
//                                         bottomRight.x - topLeft.x,
//                                         bottomRight.y - topLeft.y);
//    return outMapRect;
    
    
    CLLocationCoordinate2D northEast = [self.mapView.projection coordinateForPoint:
                                        CGPointMake(targetedMaxX, targetedMaxY)];
    CLLocationCoordinate2D southWest = [self.mapView.projection coordinateForPoint:
                                        CGPointMake(targetedMinX, targetedMinY)];
    
    GMSCoordinateBounds *outBounds = [[GMSCoordinateBounds alloc]
                                      initWithCoordinate: northEast
                                      coordinate: southWest];
    return outBounds;
    
}










// This function computes the ideal targetedMin and targetedMax
// based on the provided information
void findTargetedMinMax(double leftEdge, double anchorMapPoint, double rightEdge
                        ,double minMapPoint, double maxMapPoint,
                        double *targetedMin, double *targetedMax)
{
    // Initial condition
    // |--left--a--right--|
    
    // Check if anchor is in between min and max
    if (anchorMapPoint <= minMapPoint){
        //  --a--minMapPointX, maxMapPointX--
        
        //want:
        // |--a--minMapPointX maxMapPointX|
        *targetedMax = maxMapPoint;
        *targetedMin = anchorMapPoint -
        (maxMapPoint - anchorMapPoint)
        * (anchorMapPoint - leftEdge)/(rightEdge - anchorMapPoint);
        
    }else if (anchorMapPoint > minMapPoint &&
              anchorMapPoint <= maxMapPoint)
    {
        //  --minMapPointX -- a -- maxMapPointX--
        
        //want:
        // |minMapPointX -- a -- maxMapPointX|
        
        // Need to figure out which end is the dominant end
        double currentLeftDelta, currentRightDelta;
        // | currentLeftDelta-- a -- currentRightDelta|
        currentLeftDelta = anchorMapPoint - leftEdge;
        currentRightDelta = rightEdge - anchorMapPoint;
        
        // minMapPointX --deltaToMin-- a --deltaToMax-- maxMapPointX
        double deltaToMin, deltaToMax;
        deltaToMin = anchorMapPoint - minMapPoint;
        deltaToMax = maxMapPoint - anchorMapPoint;
        
        if ((currentLeftDelta/currentRightDelta) > (deltaToMin/deltaToMax)){
            // Left end is dominant
            // |minMapPointX -- a -- maxMapPointX------|
            *targetedMin = anchorMapPoint - deltaToMax / currentRightDelta * currentLeftDelta;
            *targetedMax = maxMapPoint;
        }else{
            // Right end is dominant
            // |-------minMapPointX -- a -- maxMapPointX|
            *targetedMin = minMapPoint;
            *targetedMax = anchorMapPoint + deltaToMin / currentLeftDelta * currentRightDelta;
        }
        
    }else{
        //  |minMapPointX -- maxMapPointX--a--|
        
        //want:
        // |minMapPointX maxMapPointX--a--|
        double deltaToMin = anchorMapPoint - minMapPoint;
        double currentLeftDelta = anchorMapPoint - leftEdge;
        double currentRightDelta = rightEdge - anchorMapPoint;
        
        *targetedMin = minMapPoint;
        *targetedMax = anchorMapPoint + deltaToMin / currentLeftDelta * currentRightDelta;
    }
}

// this method makes the map snap to two POIs
- (void) snapToTwoTokens: (NSSet*) tokenSet{
    
    CLLocationCoordinate2D coords[2];
    CGPoint cgPoints[2];
    int i = 0;
    for (SpaceToken *aToken in tokenSet){
        coords[i] = aToken.spatialEntity.latLon;
        cgPoints[i] = aToken.mapViewXY;
        i++;
    }
    [self.mapView snapTwoCoordinates: coords toTwoXY: cgPoints];
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
