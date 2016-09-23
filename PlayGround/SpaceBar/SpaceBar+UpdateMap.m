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
    for(SpaceToken* anItem in self.draggingSet) {
        if (anItem.type != ANCHORTOKEN){
            SpaceToken* aMark = (SpaceToken*)anItem;
            aMark.mapViewXY = aMark.center;
        }
    }
}

// This method finds the (x, y) corrdinates corresponding to the (lat, lon)
// of each POI, and fills that information into each POI.
// This is useful for POI sorting on SpaceBar
- (void) fillMapXYsForSet: (NSSet*) aSet{
    for (SpaceToken* aToken in aSet){
        aToken.mapViewXY = [self.mapView convertCoordinate:aToken.poi.latLon
                                           toPointToView:self.mapView];
    }
}

//----------------
// zoom-to-fit
//----------------
- (void) zoomMapToFitTouchSet{
    
    if ([self.anchorArray count]==1){
        //--------------
        // One anchor
        //--------------
        // Show the anchor and one desired location
        SpaceToken *oneAnchor = self.anchorArray[0];
        
        MKMapRect mapRect = [self computerBoundingPOIsForTokenSets: self.touchingSet
                                                         andAnchor: oneAnchor];
        
        // Turn on the debug visual
        oneAnchor.isLineLayerOn = YES;
        oneAnchor.isConstraintLineOn = YES;
        [self.mapView setVisibleMapRect:mapRect edgePadding:self.mapView.edgeInsets
                               animated:NO];
    }else{
        //--------------
        // Zero anchor, or more than one anchor
        //--------------
        
        // Put POIs in touchingSet into a poiSet
        NSMutableSet <POI*>* poiSet =
        [[NSMutableSet alloc] init];
        for (SpaceToken* aToken in self.touchingSet){
            [poiSet addObject: aToken.poi];
        }
        
        // Put POIs in anchorArray into a poiSet
        for (SpaceToken *aToken in self.anchorArray){
            [poiSet addObject:aToken.poi];
            // Draw the constraint line
            aToken.isConstraintLineOn = YES;
        }
        
        // Zoom to fit
        [self.mapView zoomToFitPOIs:poiSet];
    }
}

//----------------
// zoom-to-preference
//----------------
- (void) updateMapToFitPOIPreferences: (NSMutableSet*) tokenSet{
    
    BOOL isAnchorInDraggingSet = NO;
    if ([self.anchorArray count]>0){
        NSMutableSet *intersectSet = [NSMutableSet setWithSet:tokenSet];
        [intersectSet intersectSet:[NSSet setWithArray:self.anchorArray]];
        if ([intersectSet count] > 0){
            isAnchorInDraggingSet = YES;
        }
    }
    
    // this is to support anchor+X
    // one anchor + one dragging SpaceToken
    if ([tokenSet count] == 1
        && !isAnchorInDraggingSet
        && [self.anchorArray count]==1)
    {
        SpaceToken *anchor = self.anchorArray[0];
        anchor.isCircleLayerOn = YES;
        [self.draggingSet addObject:anchor];
    }
    
    // Assume there are at most two POIs
    if ([tokenSet count] == 1)
    {
        //----------------------
        // Snap to one SpaceToken
        //----------------------
        SpaceToken *aToken = [tokenSet anyObject];
        [self.mapView snapOneCoordinate: aToken.poi.latLon toXY: aToken.mapViewXY
                        withOrientation:self.mapView.camera.heading animated:NO];
    }else if ([tokenSet count] == 2){
        
        //----------------------
        // Snap to two SpaceTokens
        //----------------------
        [self snapToTwoTokens: tokenSet];
    }
}


//------------------
// Compute the bounding box that includes an anchor and tokens
//------------------
- (MKMapRect)computerBoundingPOIsForTokenSets: (NSSet*)tokenSet
                                       andAnchor: (SpaceToken*) anchor
{
    // Compute the bounding POIs
    CGFloat minCGPointX, maxCGPointX, minCGPointY, maxCGPointY;
    
    // To initialize the search
    SpaceToken *aToken = [tokenSet anyObject];
    CGPoint aCGPoint = [self.mapView convertCoordinate: aToken.poi.latLon
                                         toPointToView: self.mapView];
    minCGPointX = aCGPoint.x; maxCGPointX = aCGPoint.x;
    minCGPointY = aCGPoint.y; maxCGPointY = aCGPoint.y;
    
    for (SpaceToken *aToken in tokenSet){
        CGPoint tempMapPoint = [self.mapView convertCoordinate: aToken.poi.latLon
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
    
    // Generate MapRect (first need to convert from CGPoint to MapPoints)
    MKMapPoint topLeft =
    MKMapPointForCoordinate(
          [self.mapView convertPoint:CGPointMake(targetedMinX, targetedMinY)
                toCoordinateFromView: self.mapView]);
    
    MKMapPoint bottomRight =
    MKMapPointForCoordinate(
                            [self.mapView convertPoint:CGPointMake(targetedMaxX, targetedMaxY)
                                  toCoordinateFromView: self.mapView]);
    
    MKMapRect outMapRect = MKMapRectMake(topLeft.x, topLeft.y,
                                      bottomRight.x - topLeft.x,
                                      bottomRight.y - topLeft.y);
    return outMapRect;
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
        coords[i] = aToken.poi.latLon;
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
