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
#include "CustomMKPolyline.h"
#include "Route+Appearance.h"

using namespace std;

template class std::vector<pair<int, int>>;
template class std::vector<double>;

//============================
// Route class
//============================
@implementation Route

-(id)init{
    self = [super init];
    self.appearanceMode = ROUTEMODE;
    [self addObserver:self forKeyPath:@"dirtyFlag" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    return self;
}

// MARK: Initialization
- (id)initWithMKRoute: (MKRoute *) aRoute Source:(POI *)source Destination:(POI *)destination
{
    self = [super initWithMKPolyline:aRoute.polyline];
    self.appearanceMode = ROUTEMODE;
    [self setContent: [NSMutableArray arrayWithObjects:source, destination, nil]];
    self.name = [NSString stringWithFormat:@"%@ - %@", source.name, destination.name];
    return self;
}

- (id)initWithMKMapPointArray: (NSArray*) mapPointArray{
    
    self = [super initWithMKMapPointArray:mapPointArray];
    self.appearanceMode = SKETCHEDROUTE;
    // Construct source and destination
    POI *sourcePOI = [[POI alloc] init];
    sourcePOI.name = @"source";
    sourcePOI.latLon = MKCoordinateForMapPoint([mapPointArray[0] MKMapPointValue]);
    
    
    POI *destinationPOI = [[POI alloc] init];
    sourcePOI.name = @"destination";
    sourcePOI.latLon = MKCoordinateForMapPoint([[mapPointArray lastObject] MKMapPointValue]);
    
    [self setContent: [NSMutableArray arrayWithObjects:sourcePOI, destinationPOI, nil]];
    
    self.name = [NSString stringWithFormat:@"%@ - %@", sourcePOI.name, destinationPOI.name];
    return self;
}


//----------------
// MARK: --Setters--
//----------------
-(void)setAppearanceMode:(AppeararnceMode)appearanceMode{
    _appearanceMode = appearanceMode;
    
    switch (self.appearanceMode) {
        case ARRAYMODE:
            [self updateArrayForContentArray];
            break;
        case SETMODE:
            [self updateSetForContentArray];
            break;
        case ROUTEMODE:
            [self updateRouteForContentArray];
            break;
        case SKETCHEDROUTE:
            // Do nothing
            break;
    }
    self.dirtyFlag = @0;
    
    if (self.appearanceChangedHandlingBlock){
        self.appearanceChangedHandlingBlock();
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"dirtyFlag"] && object == self)
    {
        if (self.appearanceMode == ARRAYMODE){
            [self updateArrayForContentArray];
        }
        
    }
}

//----------------
// MARK: -- Save the route --
//----------------
// saving and loading the object
- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];

    // Save the source and destination
    [coder encodeObject: self.annotationDictionary forKey:@"annotationDictionary"];
    [coder encodeObject: [NSNumber numberWithInt: self.appearanceMode] forKey:@"appearanceMode"];
}

- (id)initWithCoder:(NSCoder *)coder {    
    self = [super initWithCoder:coder];
    
    // Decode source and destination
    self.annotationDictionary = [coder decodeObjectOfClass:[NSMutableDictionary class] forKey:@"annotationDictionary"];
    self.appearanceMode = (AppeararnceMode)
    [[coder decodeObjectOfClass:[NSNumber class] forKey:@"appearanceMode"] intValue];
    return self;
}

// MARK: Debug
- (NSString*)description{
    NSMutableArray *lines = [NSMutableArray array];
    [lines addObject:[NSString stringWithFormat:@"Route name: %@", self.name]];
    
    if ([routeSegmentArray count] == 0){
        [lines addObject:[NSString stringWithFormat:@"Transportation type: %@",
                          [self transportationTypeToString:self.transportType]]];
        [lines addObject:[NSString stringWithFormat:@"Travel time (mins): %.2f", self.expectedTravelTime/60]];
        [lines addObject:[NSString stringWithFormat:@"Travel distance (meters): %.2f", self.distance]];
    }else{
        for (Route *aRoute in routeSegmentArray){
            [lines addObject:[aRoute description]];
        }
    }
    
    return [lines componentsJoinedByString:@"\n"];
}

-(NSString*)transportationTypeToString:(MKDirectionsTransportType)transportType{
    NSString *output;
    switch (transportType) {
        case MKDirectionsTransportTypeAutomobile:
            output = @"Car";
            break;
        case MKDirectionsTransportTypeWalking:
            output = @"Walking";
            break;
        case MKDirectionsTransportTypeTransit:
            output = @"Transit";
            break;
        case MKDirectionsTransportTypeAny:
            output = @"Any";
            break;
    }
    return output;
}


-(void)dealloc{
    [self removeObserver:self forKeyPath:@"dirtyFlag"];
}
@end
