//
//  TokenCollection.m
//  SpaceBar
//
//  Created by dmiau on 11/20/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "TokenCollection.h"

#import "SpatialEntity.h"
#import "POI.h"
#import "SpaceToken.h"

@implementation TokenCollection

+(TokenCollection*)sharedManager{
    static TokenCollection *sharedTokenCollection = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTokenCollection = [[TokenCollection alloc] init];
    });
    return sharedTokenCollection;
}

-(id)init{
    self = [super init];
    tokenArray = [[NSMutableArray alloc] init];
    self.isTokenDraggingEnabled = YES;
    self.isStudyModeEnabled = NO;
    self.isTokenLabelEnabled = NO;
    return self;
}

-(SpaceToken*)findSpaceTokenFromEntity:(SpatialEntity*)entity{
    SpaceToken *outToken = nil;
    
    for (SpaceToken *aToken in tokenArray){
        if ([aToken isEqual:entity]){
            outToken = aToken;
        }
    }
    return outToken;
}

-(void)setIsTokenDraggingEnabled:(BOOL)isTokenDraggingEnabled{
    _isTokenDraggingEnabled = isTokenDraggingEnabled;
    
    for (SpaceToken *aToken in tokenArray){
        aToken.isDraggable = _isTokenDraggingEnabled;
    }
}

-(void)setIsStudyModeEnabled:(BOOL)isStudyModeEnabled{
    _isStudyModeEnabled = isStudyModeEnabled;
    for (SpaceToken *aToken in tokenArray){
        aToken.isStudyModeEnabled = _isStudyModeEnabled;
    }
    
    if (!isStudyModeEnabled){
        self.isTokenDraggingEnabled = YES;
    }
}

-(void)setIsTokenLabelEnabled:(BOOL)isTokenLabelEnabled{
    _isTokenLabelEnabled = isTokenLabelEnabled;
    for (SpaceToken *aToken in tokenArray){
        aToken.spatialEntity.annotation.isLableOn = isTokenLabelEnabled;
    }
}

-(void)resetAnnotationColor{
    for (SpaceToken *aToken in tokenArray){
        
        // Remove the hightlight of all SpaceTokens
        aToken.spatialEntity.annotation.isHighlighted = NO;
        aToken.spatialEntity.isMapAnnotationEnabled = NO;
        aToken.spatialEntity.isMapAnnotationEnabled = YES;
    }
}

//------------------
// Add and remove tokens
//------------------
- (void)addToken:(SpaceToken *)aToken{
    [tokenArray addObject:aToken];
    aToken.isStudyModeEnabled = self.isStudyModeEnabled;
    aToken.isDraggable = self.isTokenDraggingEnabled;
}


- (void)removeToken:(SpaceToken *)aToken{
    [tokenArray removeObject:aToken];
}

- (void)removeAllTokens{
    [tokenArray removeAllObjects];
}

- (NSArray <SpaceToken*>*)getTokenArray{
    NSArray *outArray = [NSArray arrayWithArray:tokenArray];
    return outArray;
}

@end
