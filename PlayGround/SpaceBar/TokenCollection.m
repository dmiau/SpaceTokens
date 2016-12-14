//
//  TokenCollection.m
//  SpaceBar
//
//  Created by dmiau on 11/20/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "TokenCollection.h"

#import "SpatialEntity.h"
#import "SpaceToken.h"

@implementation TokenCollection


+(TokenCollection*)sharedManager{
    static TokenCollection *sharedTokenCollection = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTokenCollection = [[TokenCollection alloc] init];
        sharedTokenCollection.tokenArray = [[NSMutableArray alloc] init];
        sharedTokenCollection.isTokenDraggingEnabled = YES;

    });
    return sharedTokenCollection;
}

//-(id)init{
//    self = [super init];
//    
//}


-(SpaceToken*)findSpaceTokenFromEntity:(SpatialEntity*)entity{
    SpaceToken *outToken = nil;
    
    for (SpaceToken *aToken in self.tokenArray){
        if ([aToken isEqual:entity]){
            outToken = aToken;
        }
    }
    return outToken;
}

-(void)setIsTokenDraggingEnabled:(BOOL)isTokenDraggingEnabled{
    _isTokenDraggingEnabled = isTokenDraggingEnabled;
    
    for (SpaceToken *aToken in self.tokenArray){
        aToken.isDraggable = _isTokenDraggingEnabled;
    }
}

-(void)resetAnnotationColor{
    for (SpaceToken *aToken in self.tokenArray){
        aToken.spatialEntity.annotation.pointType = LANDMARK;
    }
}

@end
