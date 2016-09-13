//
//  POIDatabase.m
//  SpaceBar
//
//  Created by dmiau on 7/20/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "POIDatabase.h"


@implementation POIDatabase{
    NSMutableArray <POI*> *cacheDefaultPOIArray;
}

+(POIDatabase*)sharedManager{
    static POIDatabase *sharedPOIDatabase = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPOIDatabase = [[POIDatabase alloc] init];
    });
    return sharedPOIDatabase;
}

- (id) init{
    self.poiArray = [[NSMutableArray alloc] init];
    cacheDefaultPOIArray = [[NSMutableArray alloc] init];
    useDefaultPOIArray = YES;
    return self;
}

- (void)setPoiArray:(NSMutableArray<POI *> *)poiArray{
    if (useDefaultPOIArray){
        cacheDefaultPOIArray = poiArray;
    }
    _poiArray = poiArray;
}

// methods to support a temporary POI array
- (void)useTempPOIArray:(NSMutableArray*)tempArray{
    useDefaultPOIArray = NO;
    self.poiArray = tempArray;
}

- (void)removeTempPOIArray{
    useDefaultPOIArray = YES;
    self.poiArray = cacheDefaultPOIArray;
}

// saving and loading the object
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.poiArray forKey:@"poiArray"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [self init];
    self.name = [coder decodeObjectForKey:@"name"];
    self.poiArray = [[coder decodeObjectForKey:@"poiArray"] mutableCopy];
    return self;
}

//- (NSString*)description{
//    return @"";
//}

@end
