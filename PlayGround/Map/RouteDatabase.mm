//
//  RouteDatabase.m
//  SpaceBar
//
//  Created by Daniel on 8/4/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "RouteDatabase.h"
#import "MyFileManager.h"
#import "POI.h"

@implementation RouteDatabase

+(RouteDatabase*)sharedManager{
    static RouteDatabase *sharedRouteDatabase = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedRouteDatabase = [[RouteDatabase alloc] init];
    });
    
    return sharedRouteDatabase;
}

- (id) init{
    self = [super init];
    if (self){
        self.routeDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

// Pre-load some routes into memory
- (void)reloadRouteDB{

//    [self getRoutesFromNetwork];
    
    MyFileManager *myFileManager = [MyFileManager sharedManager];
    
    NSString *dirPath = [myFileManager currentFullDirectoryPath];
    NSString *fileFullPath = [dirPath stringByAppendingPathComponent:@"myTest.routedb"];
    [self loadFromFile:fileFullPath];
    
}

- (void) getRoutesFromNetwork
{
    // New York to Boston
    POI *NewYork = [[POI alloc] init];
    NewYork.latLon = CLLocationCoordinate2DMake(40.712784, -74.005941);
    NewYork.name = @"New York";
    
    POI *Boston = [[POI alloc] init];
    Boston.latLon = CLLocationCoordinate2DMake(42.360082, -71.058880);
    Boston.name = @"Boston";
    
    [self addRouteWithSource:NewYork Destination:Boston];
    
    // London to Cambridge
    POI *London = [[POI alloc] init];
    London.latLon = CLLocationCoordinate2DMake(51.507351, -0.127758);
    London.name = @"London";
    
    POI *Cambridge = [[POI alloc] init];
    Cambridge.latLon = CLLocationCoordinate2DMake(52.205337, 0.121817);
    Cambridge.name = @"Cambridge";
    
    [self addRouteWithSource:London Destination:Cambridge];
    
    
    // Edgewater, NJ to Columbia
    POI *Edgewater = [[POI alloc] init];
    Edgewater.latLon = CLLocationCoordinate2DMake(40.827045, -73.975694);
    Edgewater.name = @"Edgewater, NJ";
    
    POI *Columbia = [[POI alloc] init];
    Columbia.latLon = CLLocationCoordinate2DMake(40.807722, -73.964110);
    Columbia.name = @"Columbia";
    
    [self addRouteWithSource:Edgewater Destination:Columbia];
    
    // Munich to Copenhagen
    POI *Munich = [[POI alloc] init];
    Munich.latLon = CLLocationCoordinate2DMake(48.135125, 11.581981);
    Munich.name = @"Munich";
    
    POI *Copenhagen = [[POI alloc] init];
    Copenhagen.latLon = CLLocationCoordinate2DMake(55.676097, 12.568337);
    Copenhagen.name = @"Copenhagen";
    
    [self addRouteWithSource:Munich Destination:Copenhagen];
}

- (void) addRouteWithSource:(POI*) source Destination:(POI*) destination
{
    // Get the direction from New York to Boston
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
             [self initRouteObject:response];
             NSLog(@"Direction response received!");
         }
         //         [self updateSpaceBar];
     }];
}

// Initialize the route object
- (void) initRouteObject: (MKDirectionsResponse *) response{
    
    // There could be multiple routes
    for (MKRoute *route in response.routes)
    {        
        POI *source = [[POI alloc] init];
        source.name = response.source.name;
        source.latLon = response.source.placemark.coordinate;
        
        POI *destination = [[POI alloc] init];
        destination.name = response.destination.name;
        destination.latLon = response.destination.placemark.coordinate;
        
        Route *aRoute = [[Route alloc] initWithMKRoute:route
                Source:source Destination:destination];
        self.routeDictionary[aRoute.name] = aRoute;
        break;
    }
}

#pragma mark --encoder/decoder--
// saving and loading the object
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.routeDictionary forKey:@"routeDictionary"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [self init];
    self.name = [coder decodeObjectForKey:@"name"];
    self.routeDictionary = [[coder decodeObjectForKey:@"routeDictionary"] mutableCopy];
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
        self.routeDictionary = routeDB.routeDictionary;
        return YES;
    }else{
        NSLog(@"%@ does not exist.", fullPathFileName);
        return NO;
    }
}

@end
