//
//  SpaceToken+Tools.m
//  NavTools
//
//  Created by Daniel on 1/3/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "SpaceToken+Tools.h"
#import "SpaceToken.h"
#import "UIButton+Extensions.h"
#import "Constants.h"
#import "CustomPointAnnotation.h"
#import "Person.h"
#import "CustomMKMapView.h"

#import "POI.h"
#import "Route.h"
#import "Area.h"
#import "ArrayEntity.h"
#import "PersonToken.h"
#import "PathToken.h"
#import "AreaToken.h"
#import "ArrayToken.h"

#import "TokenCollectionView.h"

@implementation SpaceToken (Tools)
+(SpaceToken*) manufactureTokenForEntity:(SpatialEntity*)spatialEntity{
    SpaceToken *aSpaceToken;

    if ([spatialEntity isMemberOfClass:[POI class]]){
        aSpaceToken = [[SpaceToken alloc] init];
    }else if ([spatialEntity isKindOfClass:[Person class]]){
        aSpaceToken = [[PersonToken alloc] init];
    }else if ([spatialEntity isKindOfClass:[Route class]]){
        aSpaceToken = [[PathToken alloc] init];
    }else if ([spatialEntity isKindOfClass:[Area class]]){
        aSpaceToken = [[AreaToken alloc] init];
    }else if ([spatialEntity isKindOfClass:[ArrayEntity class]]){
        aSpaceToken = [[ArrayToken alloc] init];
    }else{
        [NSException raise:@"unimplemented code path" format:@"unknown spatial entity type"];
    }
    
    aSpaceToken.spatialEntity = spatialEntity;
    return aSpaceToken;
}
@end
