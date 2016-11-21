//
//  Route+Tools.m
//  SpaceBar
//
//  Created by Daniel on 11/21/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "Route+Tools.h"
#import "POI.h"
#import "EntityDatabase.h"

@implementation Route (Tools)

+ (void) addRouteWithSource:(POI*) source Destination:(POI*) destination
{
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
         } else {
             // A response is received
//             [self initRouteObject:response];
             
             // There could be multiple routes
             for (MKRoute *route in response.routes)
             {
                 // Create a route
                 Route *aRoute = [[Route alloc] initWithMKRoute:route
                                                         Source:response.source Destination:response.destination];
                 
                 // Push the newly created route into the entity database
                 EntityDatabase *entityDatabase = [EntityDatabase sharedManager];
                 [entityDatabase.entityArray addObject:aRoute];
                 aRoute.isMapAnnotationEnabled = YES;
                 NSLog(@"Direction response received!");
                 NSLog(@"Rooute: %@ added.", aRoute.name);
                 break;
             }
             
         }
         //         [self updateSpaceBar];
     }];
}
@end
