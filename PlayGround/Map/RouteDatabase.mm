//
//  RouteDatabase.m
//  SpaceBar
//
//  Created by Daniel on 8/4/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "RouteDatabase.h"
#import "POI.h"

@implementation RouteDatabase
- (id) init{
    self = [super init];
    if (self){
        self.routeArray = [[NSMutableArray alloc] init];
    }
    return self;
}

// Pre-load some routes into memory
- (void)reloadRouteDB{
    // New York to Boston
    POI *NewYork = [[POI alloc] init];
    NewYork.latLon = CLLocationCoordinate2DMake(40.712784, -74.005941);
    NewYork.name = @"New York";

    POI *Boston = [[POI alloc] init];
    Boston.latLon = CLLocationCoordinate2DMake(42.360082, -71.058880);
    Boston.name = @"Boston";
    
    [self addRouteWithSource:NewYork Destination:Boston];
    
    // London to Cambridge
    

}

- (void) addRouteWithSource:(POI*) source Destination:(POI*) destination
{
    // Get the direction from New York to Boston
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    // Start map item (New York)
    MKPlacemark *startPlacemark = [[MKPlacemark alloc] initWithCoordinate:source.latLon addressDictionary:nil];
    MKMapItem *startMapItem = [[MKMapItem alloc] initWithPlacemark:startPlacemark];
    [startMapItem setName:source.name];
    request.source = startMapItem;
    
    // End map item (Boston)
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
             [self initRouteoBject:response];
             NSLog(@"Direction response received!");
         }
         //         [self updateSpaceBar];
     }];
}

// Initialize the route object
- (void) initRouteoBject: (MKDirectionsResponse *) response{
    
    // There could be multiple routes
    for (MKRoute *route in response.routes)
    {
        Route *aRoute = [[Route alloc] initWithMKRoute:route
                                                   Source:response.source Destination:response.destination];
        [self.routeArray addObject:aRoute];
        break;
    }
}

#pragma mark --encoder/decoder--
// saving and loading the object
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.routeArray forKey:@"routeArray"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [self init];
    self.name = [coder decodeObjectForKey:@"name"];
    self.routeArray = [[coder decodeObjectForKey:@"routeArray"] mutableCopy];
    return self;
}

//- (NSString*)description{
//    return @"";
//}


#pragma mark --iCloud related methods--
// Good reference: http://www.idev101.com/code/Objective-C/Saving_Data/NSKeyedArchiver.html

- (bool)saveDatatoFileWithName: (NSString*) fullPathFileName{
    // Save the entire database to a file
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject: self];
    
    if ([data writeToFile:fullPathFileName atomically:YES]){
        NSLog(@"%@ saved successfully!", fullPathFileName);
        return YES;
    }else{
        NSLog(@"Failed to save %@", fullPathFileName);
        return NO;
    }
}

- (bool)loadFromFile:(NSString*) fullPathFileName{
    
    // Read content from a file
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:fullPathFileName]){
        
        NSData *data = [NSData dataWithContentsOfFile:fullPathFileName];
        RouteDatabase *routeDB = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        self.name = routeDB.name;
        self.routeArray = routeDB.routeArray;
        return YES;
    }else{
        NSLog(@"%@ does not exist.", fullPathFileName);
        return NO;
    }
}

@end
