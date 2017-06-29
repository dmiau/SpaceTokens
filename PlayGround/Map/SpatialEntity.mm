//
//  SpatialEntity.m
//  NavTools
//
//  Created by Daniel on 11/11/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SpatialEntity.h"
#import "CustomMKMapView.h"
#import "CustomPointAnnotation.h"

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
        _name = @"";
        _placeID = @"";
        _isEnabled = NO;
        _isAnchor = NO;
        _isMapAnnotationEnabled = YES;
        _dirtyFlag = @0;
    }
    return self;
}

//----------------
//MARK: Setters
//----------------

// Custom set methods
- (void)setLatLon:(CLLocationCoordinate2D)latLon{
    _latLon = latLon;
}


- (void)setName:(NSString *)name{
    _name = name;
}

-(void)setIsMapAnnotationEnabled:(BOOL)isMapAnnotationEnabled{
    _isMapAnnotationEnabled = isMapAnnotationEnabled;
}

- (void)setMapAnnotationEnabled:(BOOL)flag onMap:(MKMapView*)map{

}


//----------------
// MARK: --Tools--
//----------------

-(BOOL)checkVisibilityOnMap:(CustomMKMapView*) mapView{
    return [mapView containsCoordinate:self.latLon];
}

//----------------
// MARK: --Interactions--
//----------------
- (double)getPointDistanceToTouch:(UITouch*)touch{
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    MKCoordinateSpan span = mapView.region.span;
    
//    // Check the zoom level
//    if (span.latitudeDelta > 0.08 && span.longitudeDelta > 0.08)
//        return 1000;
    
    // Get the entity CGPoint
    CGPoint entityPoint = [mapView convertCoordinate:self.latLon toPointToView:mapView];
    
    // Get the touch CGPoint
    CGPoint touchPoint = [touch locationInView:mapView];
    
    // Compute the distance between them
    double distanceSquare = pow(entityPoint.x - touchPoint.x, 2) +
    pow(entityPoint.y - touchPoint.y, 2);        
    return sqrt(distanceSquare);
}

- (BOOL)isEntityTouched:(UITouch*)touch{
    
    // Alternatively, one can look into this method
    // CGPathContainsPoint
    
    if ([self getPointDistanceToTouch:touch] < 15){
        return YES;
    }else{
        return NO;
    }
}

//----------------
// MARK: --Serialization--
//----------------
- (id)initWithCoder:(NSCoder *)coder {
    self = [self init];
    self.latLon = CLLocationCoordinate2DMake([coder decodeDoubleForKey:@"latLon.latitdue"], [coder decodeDoubleForKey:@"latLon.longitude"]);
    self.name = [coder decodeObjectOfClass:[NSString class] forKey:@"name"];
    self.placeID = [coder decodeObjectOfClass:[NSString class] forKey:@"placeID"];
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
    [coder encodeObject:self.placeID forKey:@"placeID"];
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
    object.placeID = self.placeID;
    object.isEnabled = self.isEnabled;
    return object;
}


- (NSString*) description{
    
    NSMutableArray *lines = [NSMutableArray array];
    [lines addObject:[NSString stringWithFormat:@"Name: %@", self.name]];
    [lines addObject:[NSString stringWithFormat:@"latLon: %g, %g", self.latLon.latitude, self.latLon.longitude]];
    [lines addObject:[NSString stringWithFormat:@"Span: %g, %g", self.coordSpan.latitudeDelta, self.coordSpan.longitudeDelta]];
    return [lines componentsJoinedByString:@"\n"];
}

@end
