//
//  Route.m
//  SpaceBar
//
//  Created by dmiau on 6/28/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "Route.h"
#import <vector>
#import <iostream>
#import "POI.h"
#import "CustomMKMapView.h"
#include <cmath>
#include "NSValue+MKMapPoint.h"

using namespace std;

template class std::vector<pair<int, int>>;
template class std::vector<double>;

//============================
// Route class
//============================
@implementation Route

- (id)initWithMKRoute: (MKRoute *) aRoute Source:(MKMapItem *)source Destination:(MKMapItem *)destination
{
    self = [super initWithMKPolyline:aRoute.polyline];
    
    self.annotation.pointType = path;
    self.source = source;
    self.destination = destination;
    self.name = [NSString stringWithFormat:@"%@ - %@", source.name, destination.name];
    return self;
}

- (id)initWithMKMapPointArray: (NSArray*) mapPointArray{
    
    self = [super initWithMKMapPointArray:mapPointArray];
    self.annotation.pointType = path;
    
    // Construct source and destination
    CLLocationCoordinate2D sourceCoord =
    MKCoordinateForMapPoint([mapPointArray[0] MKMapPointValue]);
    MKPlacemark *sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:sourceCoord addressDictionary:nil];
    MKMapItem *sourceMapItem = [[MKMapItem alloc] initWithPlacemark:sourcePlacemark];
    [sourceMapItem setName:@"source"];
    self.source = sourceMapItem;
    
    CLLocationCoordinate2D destinationCoord =
    MKCoordinateForMapPoint([[mapPointArray lastObject] MKMapPointValue]);
    MKPlacemark *destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:
                                         destinationCoord addressDictionary:nil];
    MKMapItem *destinationMapItem = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
    [destinationMapItem setName:@"destination"];
    self.destination = destinationMapItem;
    
    self.name = [NSString stringWithFormat:@"%@ - %@", self.source.name, self.destination.name];
    return self;
}

// Make an asynchronous request for a route with the specified source and destination`
-(void)requestRouteWithSource:(POI*) source Destination:(POI*) destination{
    self.requestCompletionFlag = NO;
    
    // Get the direction from a start map item to an end map item
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    // Start map item
    MKPlacemark *startPlacemark = [[MKPlacemark alloc] initWithCoordinate:source.latLon addressDictionary:nil];
    MKMapItem *startMapItem = [[MKMapItem alloc] initWithPlacemark:startPlacemark];
    [startMapItem setName:source.name];
    request.source = startMapItem;
    
    // End map item
    MKPlacemark *endPlacemark = [[MKPlacemark alloc] initWithCoordinate:destination.latLon addressDictionary:nil];
    MKMapItem *endMapItem = [[MKMapItem alloc] initWithPlacemark:endPlacemark];
    [endMapItem setName:destination.name];
    request.destination = endMapItem;
    
    
    request.requestsAlternateRoutes = YES;
    MKDirections *directions =
    [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             // Handle Error
             UIAlertView *alert = [[UIAlertView alloc]
                                   initWithTitle:@"Direction request error."
                                   message: @"Direction request error."
                                   delegate:self
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
             [alert show];
         } else {
             
             self.annotation.pointType = path;
             self.source = response.source;
             self.destination = response.destination;
             self.name = [NSString stringWithFormat:@"%@ - %@", source.name, destination.name];
             
             NSLog(@"A direction response for the route %@ is received.",
                   self.name);
             
             // There could be multiple routes
             for (MKRoute *route in response.routes)
             {
                 // Populate a route
                 self.polyline = route.polyline;
              
                 self.requestCompletionFlag = YES;
                 if (self.routeReadyBlock){
                     self.routeReadyBlock();
                     self.routeReadyBlock = nil;
                 }
                 
                 // There could be multiple routes. Should I store them all?
                 // For now I will save one only
                 break;
             }
         }
         
     }];
}



//----------------
// MARK: -- Save the route --
//----------------
// saving and loading the object
- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];

    // Save the source and destination
    POI *sourcePOI = [[POI alloc] init];
    sourcePOI.latLon = self.source.placemark.coordinate;
    sourcePOI.name = self.source.name;
    
    POI *destinationPOI = [[POI alloc] init];
    destinationPOI.latLon = self.destination.placemark.coordinate;
    destinationPOI.name = self.destination.name;
    
    [coder encodeObject: sourcePOI forKey:@"sourcePOI"];
    [coder encodeObject: destinationPOI forKey:@"destinationPOI"];

}

- (id)initWithCoder:(NSCoder *)coder {    
    self = [super initWithCoder:coder];
    
    // Decode source and destination
    POI *sourcePOI = [coder decodeObjectOfClass:[POI class] forKey:@"sourcePOI"];
    MKPlacemark *sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:sourcePOI.latLon addressDictionary:nil];
    MKMapItem *sourceMapItem = [[MKMapItem alloc] initWithPlacemark:sourcePlacemark];
    [sourceMapItem setName:sourcePOI.name];
    self.source = sourceMapItem;
    
    POI *destinationPOI = [coder decodeObjectOfClass:[POI class] forKey:@"destinationPOI"];
    MKPlacemark *destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:destinationPOI.latLon addressDictionary:nil];
    MKMapItem *destinationMapItem = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
    [destinationMapItem setName:destinationPOI.name];
    self.destination = destinationMapItem;
    return self;
}


@end
