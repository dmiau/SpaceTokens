//
//  SpatialEntity.m
//  SpaceBar
//
//  Created by Daniel on 11/11/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SpatialEntity.h"
#import "CustomMKMapView.h"

@implementation SpatialEntity

//----------------
//MARK: --initialization--
//----------------

- (id) init{
    self = [super init];
    if (self){
        _latLon = CLLocationCoordinate2DMake(0, 0);
        _coordSpan = MKCoordinateSpanMake(0.01, 0.01);
        _annotation = [[CustomPointAnnotation alloc] init];
        _tag = @"";
        
        _isEnabled = YES;
        _isMapAnnotationEnabled = YES;
        _isHackTokenSelected = NO;
    }
    return self;
}

//----------------
//MARK: Setters
//----------------

// Custom set methods
- (void)setLatLon:(CLLocationCoordinate2D)latLon{
    _latLon = latLon;
    _annotation.coordinate = latLon;
}


- (void)setName:(NSString *)name{
    _name = name;
    _annotation.title = name;
}

-(void)setIsMapAnnotationEnabled:(BOOL)isMapAnnotationEnabled{
    _isMapAnnotationEnabled = isMapAnnotationEnabled;
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    
    if (isMapAnnotationEnabled){
        // Add the annotation
        [mapView addAnnotation:self.annotation];
    }else{
        // Remove the annotation
        [mapView removeAnnotation:self.annotation];
    }
}

//----------------
#pragma mark --Serialization--
//----------------
- (id)initWithCoder:(NSCoder *)coder {
    self = [self init];
    self.latLon = CLLocationCoordinate2DMake([coder decodeDoubleForKey:@"latLon.latitdue"], [coder decodeDoubleForKey:@"latLon.longitude"]);
    self.name = [coder decodeObjectOfClass:[NSString class] forKey:@"name"];
    self.tag = [coder decodeObjectOfClass:[NSString class] forKey:@"tag"];
    self.coordSpan = MKCoordinateSpanMake(
                                          [coder decodeDoubleForKey:@"latitudeDelta"],
                                          [coder decodeDoubleForKey:@"longitudeDelta"]);
    self.isEnabled = [coder decodeBoolForKey:@"isEnabled"];
    return self;
}



// saving and loading the object
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeDouble:self.latLon.latitude forKey:@"latLon.latitdue"];
    [coder encodeDouble:self.latLon.longitude forKey:@"latLon.longitude"];
    [coder encodeDouble:self.coordSpan.latitudeDelta forKey:@"latitudeDelta"];
    [coder encodeDouble:self.coordSpan.longitudeDelta forKey:@"longitudeDelta"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.tag forKey:@"tag"];
    [coder encodeBool:self.isEnabled forKey:@"isEnabled"];
}

// Deep copy
-(id) copyWithZone:(NSZone *) zone
{
    // This is very important, since a child class might call this method too.
    SpatialEntity *object = [[[self class] alloc] init];
    object.latLon = self.latLon;
    object.coordSpan = self.coordSpan;
    object.name = self.name;
    object.isEnabled = self.isEnabled;
    return object;
}


- (NSString*) description{
    return [NSString stringWithFormat:@"latlon: %@",
            [NSString stringWithFormat:@"%g, %g", self.latLon.latitude, self.latLon.longitude]];
}

@end
