//
//  CustomMKMapView+Tools.m
//  SpaceBar
//
//  Created by Daniel on 9/8/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "CustomMKMapView+Tools.h"

@implementation CustomMKMapView (Tools)

+ (CLLocationDirection) computeOrientationFromA: (CLLocationCoordinate2D) coordA
                                            toB: (CLLocationCoordinate2D) coordB
{
    // Use some background map manipulation to figure out the parameters
    MKMapPoint mapPointA, mapPointB;
    
    mapPointA = MKMapPointForCoordinate(coordA);
    mapPointB = MKMapPointForCoordinate(coordB);
    
    // Find out the rotation, use POI_0 as the reference
    // Convert the result to degree
    double orientation = atan2(-(mapPointB.y - mapPointA.y),
                               mapPointB.x - mapPointA.x)/M_PI * 180;
    return 90-orientation;
}

+ (MKMapRect)MKMapRectForCoordinateRegion:(MKCoordinateRegion)region
{
    MKMapPoint a = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
                                                                      region.center.latitude + region.span.latitudeDelta / 2,
                                                                      region.center.longitude - region.span.longitudeDelta / 2));
    MKMapPoint b = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
                                                                      region.center.latitude - region.span.latitudeDelta / 2,
                                                                      region.center.longitude + region.span.longitudeDelta / 2));
    return MKMapRectMake(MIN(a.x,b.x), MIN(a.y,b.y), ABS(a.x-b.x), ABS(a.y-b.y));
}

+ (BOOL) validateCoordinate:(CLLocationCoordinate2D) coord{
    if (CLLocationCoordinate2DIsValid(coord)){
        return YES;
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Map error."
                                                        message:@"setRegion failed. The given coordinate is invalid."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return NO;
    }
}


@end
