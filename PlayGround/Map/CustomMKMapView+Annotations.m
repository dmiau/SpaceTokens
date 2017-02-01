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
#import "EntityDatabase.h"
#import "DMTools.h"
#import "MapInformationSheet.h"

@implementation CustomMKMapView (Annotations)

// MARK: Handles annotation interactions

-(bool) didTapMarker:(CustomPointAnnotation *)marker{
    [[EntityDatabase sharedManager] resetAnnotations];
    
    if ([marker isKindOfClass:[CustomPointAnnotation class]]){
        marker.isHighlighted = YES;
        marker.isLabelOn = YES;
    }
//    [self setSelectedMarker: marker];
    
    SpatialEntity *matchedEntity = [[EntityDatabase sharedManager]
                                    entityForAnnotation:marker];
    
    if (!matchedEntity){
        [DMTools showAlert:@"System error." withMessage:
         @"Matched entity was not found (didTapMarker)."];
    }
    
    [EntityDatabase sharedManager].lastHighlightedEntity = matchedEntity;
    
    [self.informationSheet addSheetForEntity:matchedEntity];
    
    return YES;
}

- (void) didTapAtCoordinate:	(CLLocationCoordinate2D) coordinate
{
    [[EntityDatabase sharedManager] resetAnnotations];
    [self.informationSheet removeSheet];
}

- (void)didTapOverlay:(GMSOverlay *)overlay{
    
    [[EntityDatabase sharedManager] resetAnnotations];
    
    if ([overlay isKindOfClass:[CustomGMSPolygon class]] ||
        [overlay isKindOfClass:[CustomGMSPolyline class]])
    {
        id <AnnotationProtocol> customOverlay = overlay;
        customOverlay.isHighlighted = YES;
    }
    
    SpatialEntity *matchedEntity = [[EntityDatabase sharedManager]
                                    entityForAnnotation:overlay];
    
    if (!matchedEntity){
        [DMTools showAlert:@"System error." withMessage:
         @"Matched entity was not found (didTapOverlay)."];
    }
    
    [EntityDatabase sharedManager].lastHighlightedEntity = matchedEntity;
    [self.informationSheet addSheetForEntity:matchedEntity];
}

- (void) didTapPOIWithPlaceID:(NSString *)placeID
           name:(NSString *)name
       location:(CLLocationCoordinate2D)location
{
    [[EntityDatabase sharedManager] resetAnnotations];
    
    // Create a temporary entity
    POI *tempPOI = [[POI alloc] init];
    tempPOI.latLon = location;
    tempPOI.name = name;
    tempPOI.placeID = placeID;
    [[EntityDatabase sharedManager] addTempEntity:tempPOI];
    tempPOI.annotation.pointType = dropped;
    tempPOI.isMapAnnotationEnabled = YES;
    tempPOI.annotation.isHighlighted = YES;
    [EntityDatabase sharedManager].lastHighlightedEntity = tempPOI;
    [self.informationSheet addSheetForEntity:tempPOI];
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
