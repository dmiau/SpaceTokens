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
    // Assume there are at most two touched
    
    if ([self.touchingSet count] == 1){
        //------------------------
        // Show one SpaceToken
        //------------------------
        

        if ([self.anchorArray count]==1)
        {
            SpaceToken *oneAnchor = self.anchorArray[0];
            //====================
            // this is to support anchor+X
            // one anchor + one touched SpaceToken
            //====================
            
            // Turn on the touching visualization
            oneAnchor.isCircleLayerOn = YES;
            
            SpaceToken *aSpaceToken = [self.touchingSet anyObject];
            aSpaceToken.mapViewXY =
            CGPointMake(aSpaceToken.center.x - aSpaceToken.frame.size.width *0.7, aSpaceToken.center.y);
            
            NSMutableSet* aSet = [[NSMutableSet alloc] init];
            [aSet addObject:aSpaceToken];
            [aSet addObject:oneAnchor];
            
            // This part needs to be fixed
            
            [self snapToTwoTokens:  aSet];
        }else if ([self.anchorArray count]==0){
            
            
            //====================
            // one SpaceToken is pressed (no anchors)
            //====================
            
            SpaceToken *aSpaceToken = [self.touchingSet anyObject];
            aSpaceToken.mapViewXY = CGPointMake(self.mapView.frame.size.width/2, self.mapView.frame.size.height/2);
            
            [self.mapView snapOneCoordinate: aSpaceToken.poi.latLon
                                       toXY: aSpaceToken.mapViewXY animated:NO];
        }else if ([self.anchorArray count]>1){
            
            
            //====================
            // one SpaceToken is pressed (with anchors)
            //====================
            NSMutableSet <POI*>* poiSet =
            [[NSMutableSet alloc] init];
            SpaceToken *aToken = [self.touchingSet anyObject];
            [poiSet addObject: aToken.poi];
            
            //----------------------
            // Relaxed constraints if an anchor is present
            //----------------------
            for (SpaceToken *aToken in self.anchorArray){
                [poiSet addObject:aToken.poi];
                // Draw the constraint line
                aToken.isConstraintLineOn = YES;
            }
            
            [self.mapView zoomToFitPOIs:poiSet];
        }
        
    }else if ([self.touchingSet count] > 1){

        NSMutableSet <POI*>* poiSet =
        [[NSMutableSet alloc] init];
        for (SpaceToken* aToken in self.touchingSet){
            [poiSet addObject: aToken.poi];
        }
        
        //----------------------
        // Relaxed constraints if an anchor is present
        //----------------------
        if ([self.anchorArray count]>0){
            
            for (SpaceToken *aToken in self.anchorArray){
                [poiSet addObject:aToken.poi];
                // Draw the constraint line
                aToken.isConstraintLineOn = YES;
            }
        }
        
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
        
//        if (isAnchorInDraggingSet){
//            NSLog(@"anchor: %@", [tokenSet anyObject]);
//        }
        
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
