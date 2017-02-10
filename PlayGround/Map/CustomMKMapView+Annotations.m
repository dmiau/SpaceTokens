//
//  CustomMKMapView+Annotations.m
//  SpaceBar
//
//  Created by dmiau on 9/28/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "CustomMKMapView+Annotations.h"
#import "CustomPointAnnotation.h"
#import "CustomMKPolygon.h"
#import "CustomGMSPolygon.h"
#import "CustomMKPolyline.h"
#import "CustomGMSPolyline.h"
#import "POI.h"
#import "HighlightedEntities.h"
#import "EntityDatabase.h"
#import "DMTools.h"
#import "MapInformationSheet.h"

@implementation CustomMKMapView (Annotations)

- (void)refreshAnnotations{
    [self clear];
    [[HighlightedEntities sharedManager] clearHighlightedSet];
    
    // Add all the entities to the map
    for (SpatialEntity *entity in [[EntityDatabase sharedManager] getEntityArray])
    {
        entity.isMapAnnotationEnabled = YES;
        entity.annotation.isHighlighted = NO;
    }
}

// MARK: Handles annotation interactions

-(bool) didTapMarker:(CustomPointAnnotation *)marker{
    
//    [self setSelectedMarker: marker];
    
    SpatialEntity *matchedEntity = [[EntityDatabase sharedManager]
                                    entityForAnnotation:marker];
    
    if (!matchedEntity){
        [DMTools showAlert:@"System error." withMessage:
         @"Matched entity was not found (didTapMarker)."];
    }
    
    [[HighlightedEntities sharedManager] addEntity: matchedEntity];
    
    return YES;
}

- (void) didTapAtCoordinate:	(CLLocationCoordinate2D) coordinate
{
    [[HighlightedEntities sharedManager] clearAllHIghlightedEntitiesButType:
     SEARCH_RESULT];
    [self.informationSheet removeSheet];
}

- (void)didTapOverlay:(GMSOverlay *)overlay{
    
    SpatialEntity *matchedEntity = [[EntityDatabase sharedManager]
                                    entityForAnnotation:overlay];
    
    if (!matchedEntity){
        [DMTools showAlert:@"System error." withMessage:
         @"Matched entity was not found (didTapOverlay)."];
    }else{
        [[HighlightedEntities sharedManager] addEntity: matchedEntity];
    }    
}

- (void)didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate{
    
    // Create a temporary entity
    POI *tempPOI = [[POI alloc] init];
    tempPOI.latLon = coordinate;
    tempPOI.name = @"Dropped";
    tempPOI.placeID = @"";
    tempPOI.annotation.pointType = DROPPED;
    
    [[HighlightedEntities sharedManager] addEntity: tempPOI];
}

- (void) didTapPOIWithPlaceID:(NSString *)placeID
           name:(NSString *)name
       location:(CLLocationCoordinate2D)location
{
    
    // Create a temporary entity
    POI *tempPOI = [[POI alloc] init];
    tempPOI.latLon = location;
    tempPOI.name = name;
    tempPOI.placeID = placeID;
    tempPOI.annotation.pointType = DROPPED;

     [[HighlightedEntities sharedManager] addEntity: tempPOI];
    
//    [self setSelectedMarker:tempPOI.annotation];
    
//    infoMarker = [GMSMarker markerWithPosition:location];
//    //    infoMarker.snippet = placeID;
//    infoMarker.title = name;
//    infoMarker.opacity = 0;
//    CGPoint pos = infoMarker.infoWindowAnchor;
//    pos.y = 1;
//    infoMarker.infoWindowAnchor = pos;
//    infoMarker.map = mapView;
//    mapView.selectedMarker = infoMarker;
}

@end
