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

- (void) zoomMapToFitTouchSet{
    // Assume there are at most two touched
    
    if ([self.touchingSet count] == 1){
        POI *aPOI = [self.touchingSet anyObject];
        aPOI.mapViewXY = CGPointMake(self.mapView.frame.size.width/2, self.mapView.frame.size.height/2);
        
        [self updateMapToFitPOIs:self.touchingSet];
        
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
        
        MKMapRect zoomRect = MKMapRectMake
        (minMapPointX, minMapPointY,
         maxMapPointX-minMapPointX, maxMapPointY - minMapPointY);
        [self.mapView setVisibleMapRect:zoomRect animated:NO];
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
        
        self.mapView.centerCoordinate = [self.mapView convertPoint:
            CGPointMake(targetCGPoint.x + diffX, targetCGPoint.y + diffY)
                                              toCoordinateFromView: self.mapView];
    }else if ([poiSet count] == 2){
        	
        
        
        
        
    }
}

@end
