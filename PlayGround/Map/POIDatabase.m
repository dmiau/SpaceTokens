//
//  POIDatabase.m
//  SpaceBar
//
//  Created by dmiau on 7/20/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "POIDatabase.h"


@implementation POIDatabase

- (id) init{
    self = [super init];
    if (self){
        self.poiArray = [[NSMutableArray alloc] init];
        
        
        //----------------------
        // Initialize file storage
        //----------------------
        BOOL result = NO;
        
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        
        NSURL *containerURL =
        [fileManager URLForUbiquityContainerIdentifier:nil];
        
        NSString *documentsDirectory =
        [[containerURL path]
         stringByAppendingPathComponent:@"Documents"];
        
        self.documentDirectory = documentsDirectory;
        
        
        
        
        BOOL isDirectory = NO;
        BOOL mustCreateDocumentsDirectory = NO;
        
        if ([fileManager fileExistsAtPath:documentsDirectory
                              isDirectory:&isDirectory]){
            if (isDirectory == NO){
                mustCreateDocumentsDirectory = YES;
            }
        } else {
            mustCreateDocumentsDirectory = YES;
        }
        
        if (mustCreateDocumentsDirectory){
            NSLog(@"Must create the directory.");
            
            NSError *directoryCreationError = nil;
            
            if ([fileManager createDirectoryAtPath:documentsDirectory
                       withIntermediateDirectories:YES
                                        attributes:nil
                                             error:&directoryCreationError]){
                result = YES;
                NSLog(@"Successfully created the folder.");
            } else {
                NSLog(@"Failed to create the folder with error = %@",
                      directoryCreationError);
            }
            
        } else {
            NSLog(@"This folder already exists.");
            result = YES;
        }
        
        
    }
    return self;
}


- (void)reloadPOI{
    [self.poiArray removeAllObjects];

    POI *poi1 = [[POI alloc] init];
    poi1.latLon = CLLocationCoordinate2DMake(40.885722, -73.912491);
    poi1.name = @"Home";
    [self.poiArray addObject:poi1];
    
    POI *poi2 = [[POI alloc] init];
    poi2.latLon = CLLocationCoordinate2DMake(40.807722, -73.964110);
    poi2.name = @"Columbia U.";
    [self.poiArray addObject:poi2];
    
    POI *poi3 = [[POI alloc] init];
    poi3.latLon = CLLocationCoordinate2DMake(40.711801, -74.013120);
    poi3.name = @"W.T.C.";
    [self.poiArray addObject:poi3];
    
    POI *poi4 = [[POI alloc] init];
    poi4.latLon = CLLocationCoordinate2DMake(42.360082, -71.058880);
    poi4.name = @"Boston";
    [self.poiArray addObject:poi4];
    
    POI *poi5 = [[POI alloc] init];
    poi5.latLon = CLLocationCoordinate2DMake(40.752726, -73.977229);
    poi5.name = @"Grand Central";
    [self.poiArray addObject:poi5];
    
    POI *poi6 = [[POI alloc] init];
    poi6.latLon = CLLocationCoordinate2DMake(40.767499, -73.833079);
    poi6.name = @"Flushing, Queens";
    [self.poiArray addObject:poi6];
    
    
//    POI *poi1 = [[POI alloc] init];
//    poi1.latLon = CLLocationCoordinate2DMake(40.712784, -74.005941);
//    poi1.name = @"NY Downtown";
//    [self.poiArray addObject:poi1];
//    
//    POI *poi2 = [[POI alloc] init];
//    poi2.latLon = CLLocationCoordinate2DMake(40.807722, -73.964110);
//    poi2.name = @"Columbia U.";
//    [self.poiArray addObject:poi2];
//    
//    POI *poi3 = [[POI alloc] init];
//    poi3.latLon = CLLocationCoordinate2DMake(37.774929, -122.419416);
//    poi3.name = @"San Francisco";
//    [self.poiArray addObject:poi3];
//    
//    POI *poi4 = [[POI alloc] init];
//    poi4.latLon = CLLocationCoordinate2DMake(42.360082, -71.058880);
//    poi4.name = @"Boston";
//    [self.poiArray addObject:poi4];
//
//    POI *poi5 = [[POI alloc] init];
//    poi5.latLon = CLLocationCoordinate2DMake(51.507351, -0.127758);
//    poi5.name = @"London";
//    [self.poiArray addObject:poi5];
//
//    POI *poi6 = [[POI alloc] init];
//    poi6.latLon = CLLocationCoordinate2DMake(48.856614, 2.352222);
//    poi6.name = @"Paris";
//    [self.poiArray addObject:poi6];
    
//    POI *poi5 = [[POI alloc] init];
//    poi5.latLon = CLLocationCoordinate2DMake(35.689487, 139.691706);
//    poi5.name = @"Tokyo";
//    [self.poiArray addObject:poi5];
}

// saving and loading the object
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.poiArray forKey:@"poiArray"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [self init];    
    self.poiArray = [[coder decodeObjectForKey:@"poiArray"] mutableCopy];
    return self;
}

//- (NSString*)description{
//    return @"";
//}

@end
