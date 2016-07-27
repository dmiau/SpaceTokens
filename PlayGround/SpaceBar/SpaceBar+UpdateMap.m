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
            aMark.poi.mapViewXY = aMark.center;
        }
    }
}

// This method finds the (x, y) corrdinates corresponding to the (lat, lon)
// of each POI, and fills that information into each POI.
// This is useful for POI sorting on SpaceBar
- (void) fillMapXYsForSet: (NSSet*) aSet{
    for (SpaceToken* aToken in aSet){
        aToken.poi.mapViewXY = [self.mapView convertCoordinate:aToken.poi.latLon
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
            aSpaceToken.poi.mapViewXY =
            CGPointMake(aSpaceToken.center.x - aSpaceToken.frame.size.width *0.7, aSpaceToken.center.y);
            
            NSMutableSet* aSet = [[NSMutableSet alloc] init];
            [aSet addObject:aSpaceToken];
            [aSet addObject:self.anchor];
            [self snapToTwoTokens:  aSet];
        }else{
            SpaceToken *aSpaceToken = [self.touchingSet anyObject];
            aSpaceToken.poi.mapViewXY = CGPointMake(self.mapView.frame.size.width/2, self.mapView.frame.size.height/2);
            [self updateMapToFitPOIPreferences:self.touchingSet];
        }
                
    }else if ([self.touchingSet count] > 1){
        NSMutableSet <POI*>* poiSet = [[NSMutableSet alloc] init];
        for (SpaceToken* aToken in self.touchingSet){
            [poiSet addObject: aToken.poi];
        }
        [self.mapView zoomToFitPOIs:poiSet];
        
//        // Clear the touching set
//        [self.touchingSet removeAllObjects];
    }
}

//----------------
// zoom-to-preference
//----------------
- (void) updateMapToFitPOIPreferences: (NSMutableSet*) tokenSet{
    
    // this is to support anchor+X
    // one anchor + one dragging SpaceToken
    if ([self.draggingSet count] == 1
        && [self.draggingSet anyObject] != self.anchor
        && self.anchor)
    {
        [self.draggingSet addObject:self.anchor];
    }
    
    // Assume there are at most two POIs
    if ([tokenSet count] == 1 &&
        [tokenSet anyObject] != self.anchor)
    {
        // The easy case
        SpaceToken *aToken = [tokenSet anyObject];
        [self snapToOneToken:aToken];
    }else if ([tokenSet count] == 2){
        [self snapToTwoTokens: tokenSet];
    }
}

// this method makes the map snap to two POIs
- (void) snapToOneToken: (SpaceToken*) aToken {
    [self.mapView snapOneCoordinate: aToken.poi.latLon toXY: aToken.poi.mapViewXY];
}


// this method makes the map snap to two POIs
- (void) snapToTwoTokens: (NSSet*) tokenSet{
    
    CLLocationCoordinate2D coords[2];
    CGPoint cgPoints[2];
    int i = 0;
    for (SpaceToken *aToken in tokenSet){
        coords[i] = aToken.poi.latLon;
        cgPoints[i] = aToken.poi.mapViewXY;
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
