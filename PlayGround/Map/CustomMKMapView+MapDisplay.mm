//
//  CustomMKMapView+MapDisplay.m
//  SpaceBar
//
//  Created by dmiau on 7/8/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "CustomMKMapView+MapDisplay.h"
#import "POI.h"
#import "Route.h"

@implementation CustomMKMapView (MapDisplay)

- (void) snapOneCoordinate: (CLLocationCoordinate2D) coord toXY: (CGPoint) viewXY
                  animated: (BOOL) animatedFlag
{
    CGFloat diffX = self.frame.size.width/2 - viewXY.x;
    CGFloat diffY = self.frame.size.height/2 - viewXY.y;
    
    // The idea:
    // Performing all the calculation on a hidden map.
    // Find the screen coordinates of the desired point (on the hidden map),
    // and then find the needed "centroid" (on the hidden map) to be able to
    // show the desired point at the specified viewXY
//    [self updateHiddenMap];
    
    CGPoint targetCGPoint = [self convertCoordinate:coord toPointToView:self];
    CLLocationCoordinate2D centroid = [self convertPoint:
                                       CGPointMake(targetCGPoint.x + diffX, targetCGPoint.y + diffY)
                                    toCoordinateFromView: self];
    [self setRegion:
     MKCoordinateRegionMake(centroid,MKCoordinateSpanMake(0.01, 0.01))
     animated:animatedFlag];
}

// Similar to the above method, but preserves the orientation
- (void) snapOneCoordinate: (CLLocationCoordinate2D) coord toXY: (CGPoint) viewXY
           withOrientation: (float) orientation animated:(BOOL)animatedFlag
{
    CGFloat diffX = self.frame.size.width/2 - viewXY.x;
    CGFloat diffY = self.frame.size.height/2 - viewXY.y;
    
    
//    [self updateHiddenMap];
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
    
    // Print out the two points
//    NSLog(@"%@", NSStringFromCGPoint(cgPoints[0]));
//    NSLog(@"%@", NSStringFromCGPoint(cgPoints[1]));

//    NSLog(@"latLon0: (%g, %g)", coords[0].latitude, coords[0].longitude);
//    NSLog(@"latLon1: (%g, %g)", coords[1].latitude, coords[1].longitude);
    
    // Use some background map manipulation to figure out the parameters
    MKMapPoint mapPoints[2];
    for (int i = 1; i < 2; i++){
        mapPoints[i] = MKMapPointForCoordinate(coords[i]);
    }
    
    hiddenMap.camera.heading = 0;
    
    // Find out the scale factor
    float desiredDistance = sqrtf(powf((cgPoints[0].x - cgPoints[1].x), 2)+
                                  powf((cgPoints[0].y - cgPoints[1].y), 2));
    CGPoint currentCGPoints[2];
    currentCGPoints[0] = [hiddenMap convertCoordinate:coords[0] toPointToView:hiddenMap];
    currentCGPoints[1] = [hiddenMap convertCoordinate:coords[1] toPointToView:hiddenMap];
    
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
//    NSLog(@"rotation: %g", rotation);
    
    // Correct the scale first
    
    // Get the current mapRect
//    CLLocationDirection heading = self.camera.heading;
//    
//    hiddenMap.camera.heading = 0;
    MKMapRect currentMapRect = hiddenMap.visibleMapRect;
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
    [hiddenMap setVisibleMapRect:newMapRect];
    hiddenMap.camera.heading = rotation/M_PI * 180;
    
    
    // Correct the translation
    CGFloat targetX = self.frame.size.width - cgPoints[0].x;
    CGFloat targetY = self.frame.size.height - cgPoints[0].y;
    
    CLLocationCoordinate2D targetCentroidLatlon = [hiddenMap
                                                   convertPoint:CGPointMake(targetX, targetY)
                                                   toCoordinateFromView:hiddenMap];
    hiddenMap.centerCoordinate = targetCentroidLatlon;
    if(CLLocationCoordinate2DIsValid(targetCentroidLatlon)){
        CLLocationDirection heading = hiddenMap.camera.heading;
        hiddenMap.camera.heading = 0;
        self.camera.heading = 0;
        
        MKMapRect aRect = hiddenMap.visibleMapRect;
        self.visibleMapRect = hiddenMap.visibleMapRect;
        self.camera.heading = heading;
//        self.centerCoordinate = targetCentroidLatlon;
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

// Zoom the map to fit the entities
- (void) zoomToFitEntities: (NSSet<SpatialEntity*> *) entitySet{
    
    if ([entitySet count] == 0){
        return;
    }else if ([entitySet count] == 1){
        //----------------
        // One Entity
        //----------------
        
        // Handle the entity differently, depending on the type of entity
        SpatialEntity *spatialEntity = [entitySet anyObject];
        
        if ([spatialEntity isKindOfClass:[POI class]]){
            POI *aPOI = spatialEntity;
            MKCoordinateRegion region;
            region.center = aPOI.latLon;
            MKCoordinateSpan span = aPOI.coordSpan;
            span.latitudeDelta = max(0.01, span.latitudeDelta);
            span.longitudeDelta = max(0.01, span.longitudeDelta);
            region.span = span;
            [self setRegion:region animated:NO];
        }else if ([spatialEntity isKindOfClass:[Route class]]){
            Route *aRoute = spatialEntity;
            [self zoomToFitRoute: aRoute];
        }
        
    }else{
        
        //----------------------------------
        // need to fit more than one point
        //----------------------------------
        
        // Goal: find minMapPointX, maxMapPOintX,
        // minMapPointY, maxMapPointY
        CGFloat minMapPointX, maxMapPointX, minMapPointY, maxMapPointY;
        
        SpatialEntity *anEntity = [entitySet anyObject];
        MKMapPoint aMapPoint = MKMapPointForCoordinate(anEntity.latLon);
        minMapPointX = aMapPoint.x; maxMapPointX = aMapPoint.x;
        minMapPointY = aMapPoint.y; maxMapPointY = aMapPoint.y;
        
        for (SpatialEntity *anEntity in entitySet){
            
            if ([anEntity isKindOfClass:[POI class]]){
                MKMapPoint tempMapPoint = MKMapPointForCoordinate(anEntity.latLon);
                minMapPointX = MIN(minMapPointX, tempMapPoint.x);
                maxMapPointX = MAX(maxMapPointX, tempMapPoint.x);
                minMapPointY = MIN(minMapPointY, tempMapPoint.y);
                maxMapPointY = MAX(maxMapPointY, tempMapPoint.y);
            }else if ([anEntity isKindOfClass:[Route class]]){
                double minMapX, maxMapX, minMapY, maxMapY;
                Route *aRoute = anEntity;
                [aRoute getMinMapX:minMapX andMaxMapX:maxMapX andMinMapY:minMapY andMaxMapY:maxMapY];
                
                minMapPointX = MIN(minMapPointX, minMapX);
                maxMapPointX = MAX(maxMapPointX, maxMapX);
                minMapPointY = MIN(minMapPointY, minMapY);
                maxMapPointY = MAX(maxMapPointY, maxMapY);
            }
        }
                
        // Find out the mid point
        MKMapPoint midPoint = {.x = .5*(maxMapPointX + minMapPointX),
            .y= .5*(maxMapPointY + minMapPointY)};
        CGFloat height = maxMapPointY - minMapPointY;
        CGFloat width = maxMapPointX - minMapPointX;
        
        // Check the aspect ratio to decide xSpan and ySpan
        CGFloat xSpan, ySpan;
        CGFloat aspectRatio =
        (self.frame.size.height - self.edgeInsets.top - self.edgeInsets.bottom)
        /(self.frame.size.width - self.edgeInsets.left - self.edgeInsets.right);
        if (height/width > aspectRatio)
        {
            ySpan = height;
            xSpan = ySpan / aspectRatio;
        }else{
            xSpan = width;
            ySpan = xSpan * aspectRatio;
        }
        
        MKMapRect zoomRect = MKMapRectMake(midPoint.x - xSpan * 0.5,
                                           midPoint.y - ySpan * 0.5,
                                           xSpan, ySpan);
        
        [self setVisibleMapRect:zoomRect edgePadding:self.edgeInsets
                       animated:NO];
    }
}

// Zoom the map to fit the route
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
    [self zoomToFitEntities:poiSet];
}

@end
