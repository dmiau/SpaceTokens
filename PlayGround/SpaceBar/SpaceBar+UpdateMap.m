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
        [self.mapView setVisibleMapRect:mapRect animated:NO];        
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
    CGFloat minMapPointX, maxMapPointX, minMapPointY, maxMapPointY;
    
    // To initialize the search
    SpaceToken *aToken = [tokenSet anyObject];
    MKMapPoint aMapPoint = MKMapPointForCoordinate(aToken.poi.latLon);
    minMapPointX = aMapPoint.x; maxMapPointX = aMapPoint.x;
    minMapPointY = aMapPoint.y; maxMapPointY = aMapPoint.y;
    
    for (SpaceToken *aToken in tokenSet){
        MKMapPoint tempMapPoint = MKMapPointForCoordinate(aToken.poi.latLon);
        minMapPointX = MIN(minMapPointX, tempMapPoint.x);
        maxMapPointX = MAX(maxMapPointX, tempMapPoint.x);
        minMapPointY = MIN(minMapPointY, tempMapPoint.y);
        maxMapPointY = MAX(maxMapPointY, tempMapPoint.y);
    }
    
    MKMapPoint anchorMapPoint = MKMapPointForCoordinate(anchor.poi.latLon);
    
    // Need to figure out the arrangement of the points
    
    MKMapRect mapRect = self.mapView.visibleMapRect;
    double leftEdge, rightEdge, topEdge, bottomEdge;
    leftEdge = mapRect.origin.x; rightEdge = mapRect.origin.x + mapRect.size.width;
    topEdge = mapRect.origin.y; bottomEdge = mapRect.origin.y + mapRect.size.height;
    
    // Goal: find targetedMinX, targetedMaxX, targetedMinY, targetedMaxY
    double targetedMinX, targetedMaxX, targetedMinY, targetedMaxY;

    // find the boubdary in the x direction
    findTargetedMinMax(leftEdge, anchorMapPoint.x, rightEdge
                       , minMapPointX, maxMapPointX,
                       &targetedMinX, &targetedMaxX);
    
    // find the boubdary in the y direction
    findTargetedMinMax(topEdge, anchorMapPoint.y, bottomEdge
                       , minMapPointY, maxMapPointY,
                       &targetedMinY, &targetedMaxY);
    
    // Need to further correct the aspect ratio
    double xDiff = targetedMaxX - targetedMinX;
    double yDiff = targetedMaxY - targetedMinY;
    
    double mapWidth = self.mapView.frame.size.width;
    double mapHeight = self.mapView.frame.size.height;
    
    if (yDiff/xDiff > mapHeight/mapWidth)
    {
        double scale = yDiff / mapHeight * mapWidth / xDiff;
        targetedMinX = anchorMapPoint.x - scale * (anchorMapPoint.x - targetedMinX);
        targetedMaxX = scale * (targetedMaxX - anchorMapPoint.x) + anchorMapPoint.x;
    }else{
        double scale = xDiff / mapWidth * mapHeight / yDiff;
        targetedMinY = anchorMapPoint.y - scale * (anchorMapPoint.y - targetedMinY);
        targetedMaxY = scale * (targetedMaxY - anchorMapPoint.y) + anchorMapPoint.y;
    }
    
    // Generate MapRect
    MKMapRect outMapRect = MKMapRectMake(targetedMinX, targetedMinY,
                                      targetedMaxX - targetedMinX,
                                      targetedMaxY - targetedMinY);
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
