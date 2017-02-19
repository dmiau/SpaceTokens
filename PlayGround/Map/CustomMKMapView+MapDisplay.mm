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
    
    CGPoint targetCGPoint = [self.projection pointForCoordinate:coord];
    
    CLLocationCoordinate2D centroid = [self.projection
                                       coordinateForPoint:CGPointMake(targetCGPoint.x + diffX, targetCGPoint.y + diffY)];
    
    if ([CustomMKMapView validateCoordinate:centroid]){
//        // Prepare a camera
//        GMSCameraPosition *newCamera = [GMSCameraPosition cameraWithTarget:centroid zoom:15];
//        [self setCamera:newCamera];
        
        [self updateCenterCoordinates:centroid];
        [self updateZoom:15];
        
    }
}

// Similar to the above method, but preserves the orientation
- (void) snapOneCoordinate: (CLLocationCoordinate2D) coord toXY: (CGPoint) viewXY
           withOrientation: (float) orientation animated:(BOOL)animatedFlag
{
    CGFloat diffX = self.frame.size.width/2 - viewXY.x;
    CGFloat diffY = self.frame.size.height/2 - viewXY.y;
    
    CGPoint targetCGPoint = [self.projection pointForCoordinate:coord];
    
    CLLocationCoordinate2D centroid = [self.projection
                                       coordinateForPoint:CGPointMake(targetCGPoint.x + diffX, targetCGPoint.y + diffY)];
    
    if ([CustomMKMapView validateCoordinate:centroid]){
        // Prepare a camera (maintain the current zoom level)
//        GMSCameraPosition *newCamera =
//        [GMSCameraPosition cameraWithTarget:centroid zoom:self.camera.zoom];
//        [self setCamera:newCamera];
        
        [self updateCenterCoordinates:centroid];
        [self updateBearing:orientation];
    }
//    // Set the orientation
//    if (orientation){
//        [self animateToBearing: orientation];
//    }
}


- (void) snapTwoCoordinates: (CLLocationCoordinate2D[2]) coords
                    toTwoXY: (CGPoint[2]) cgPoints{
    
    // Print out the two points
//    NSLog(@"%@", NSStringFromCGPoint(cgPoints[0]));
//    NSLog(@"%@", NSStringFromCGPoint(cgPoints[1]));

//    NSLog(@"latLon0: (%g, %g)", coords[0].latitude, coords[0].longitude);
//    NSLog(@"latLon1: (%g, %g)", coords[1].latitude, coords[1].longitude);
    
    // Use some background map manipulation to figure out the parameters


    // Find out the scale factor
    float desiredDistance = sqrtf(powf((cgPoints[0].x - cgPoints[1].x), 2)+
                                  powf((cgPoints[0].y - cgPoints[1].y), 2));
    CGPoint currentCGPoints[2];
    currentCGPoints[0] = [self.projection pointForCoordinate:coords[0]];
    currentCGPoints[1] = [self.projection pointForCoordinate:coords[1]];
    
    float currentDistance = sqrtf(
                                  powf((currentCGPoints[0].x - currentCGPoints[1].x), 2)+
                                  powf((currentCGPoints[0].y - currentCGPoints[1].y), 2));
    float scale = desiredDistance/currentDistance;

    // Correct the scale first
    float currentZoom = self.camera.zoom;
    float newZoom = currentZoom + logf(scale);
    
    
    // Find out the rotation, use POI_0 as the reference
    double desiredTheta = atan2(-(cgPoints[1].y - cgPoints[0].y),
                                cgPoints[1].x - cgPoints[0].x);
    double currentTheta = atan2(-(currentCGPoints[1].y - currentCGPoints[0].y),
                                currentCGPoints[1].x - currentCGPoints[0].x);
    double rotation = desiredTheta - currentTheta;
    
    // Correct the rotation
    float newBearing = self.camera.bearing + rotation/M_PI * 180;
    
    
    [self updateCenterCoordinates:coords[0]];
    [self updateZoom:newZoom];
    [self updateBearing:newBearing];
    // Correct the translation
    CGFloat targetX = self.frame.size.width - cgPoints[0].x;
    CGFloat targetY = self.frame.size.height - cgPoints[0].y;
    
    CLLocationCoordinate2D targetCentroidLatlon = [self.projection coordinateForPoint:CGPointMake(targetX, targetY)];

    if(CLLocationCoordinate2DIsValid(targetCentroidLatlon)){


        
        [self updateCenterCoordinates:targetCentroidLatlon];

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
    }else{
        
        //----------------------------------
        // need to check visibility before zoom-to-fit
        //----------------------------------
        BOOL allVisible = YES; // Assume all are visible
        
        for (SpatialEntity *entity in entitySet){
            allVisible = allVisible & [entity checkVisibilityOnMap:[CustomMKMapView sharedManager]];
        }
        
        if (allVisible && self.camera.zoom > 12){
            // No need to perform zoom-to-fit if all are visible
            return;
        }
        
        //----------------------------------
        // need to fit the entities (could be one or more)
        //----------------------------------
        SpatialEntity *anEntity = [entitySet anyObject];
                
        MKMapRect mapRect = [CustomMKMapView MKMapRectForCoordinateRegion:
                             MKCoordinateRegionMake(anEntity.latLon, anEntity.coordSpan)];
        
        for (SpatialEntity *anEntity in entitySet){
            
            MKMapRect tempMapRect = [CustomMKMapView MKMapRectForCoordinateRegion:
                                     MKCoordinateRegionMake(anEntity.latLon, anEntity.coordSpan)];
            mapRect = MKMapRectUnion(mapRect, tempMapRect);
        }
                
        // Find out the mid point
        MKMapPoint midPoint = {.x = mapRect.origin.x + .5*mapRect.size.width,
            .y= mapRect.origin.y + .5*mapRect.size.height};
        CGFloat height = mapRect.size.height;
        CGFloat width = mapRect.size.width;
        
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

@end
