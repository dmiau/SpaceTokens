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
#import "Route.h"
#import "Person.h"
#import "Area.h"
#import "SpaceToken.h"
#import "PathToken.h"
#import "AreaToken.h"

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
    self.isCustomGestureRecognizerEnabled = YES;
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

//----------------------
// Setters
//----------------------
- (void)setIsCustomGestureRecognizerEnabled:(BOOL)isCustomGestureRecognizerEnabled{
    _isCustomGestureRecognizerEnabled = isCustomGestureRecognizerEnabled;
    
    for (SpaceToken *aToken in tokenArray){
        if (aToken.isCustomGestureRecognizerEnabled != isCustomGestureRecognizerEnabled)
        {
            aToken.isCustomGestureRecognizerEnabled = isCustomGestureRecognizerEnabled;
        }
    }
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
    }
}

//------------------
// Add and remove tokens
//------------------
- (void)addToken:(SpaceToken *)aToken{
    
    if ([tokenArray count] > 12){
        self.isCustomGestureRecognizerEnabled = NO;
    }
    
    [tokenArray addObject:aToken];
    aToken.isStudyModeEnabled = self.isStudyModeEnabled;
    aToken.isDraggable = self.isTokenDraggingEnabled;
    aToken.isCustomGestureRecognizerEnabled = self.isCustomGestureRecognizerEnabled;
}

- (SpaceToken*)addTokenFromSpatialEntity:(SpatialEntity*)spatialEntity{
    SpaceToken *aSpaceToken;
    if ([spatialEntity isKindOfClass:[POI class]] ||
        [spatialEntity isKindOfClass:[Person class]]){
        aSpaceToken = [[SpaceToken alloc] init];
    }else if ([spatialEntity isKindOfClass:[Route class]]){
        aSpaceToken = [[PathToken alloc] init];
    }else if ([spatialEntity isKindOfClass:[Area class]]){
        aSpaceToken = [[AreaToken alloc] init];
    }else{
        [NSException raise:@"unimplemented code path" format:@"unknown spatial entity type"];
    }
    
    [aSpaceToken configureAppearanceForType:DOCKED];
    
    [aSpaceToken setTitle:spatialEntity.name forState:UIControlStateNormal];
    aSpaceToken.spatialEntity = spatialEntity;
    spatialEntity.linkedObj = aSpaceToken; // Establish the connection
    
    spatialEntity.isMapAnnotationEnabled = YES;
    [self addToken:aSpaceToken];
    return aSpaceToken;
}

- (void)addTokensFromEntityArray:(NSArray <SpatialEntity*>*)entityArray{
    for (SpatialEntity *spatialEntity in entityArray){
        [self addTokenFromSpatialEntity:spatialEntity];
    }
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

-(NSString*)description{
    NSMutableArray *lineArray = [NSMutableArray array];
    NSString *line = [NSString stringWithFormat:@"Gesture Mode: %d", self.isCustomGestureRecognizerEnabled];
    [lineArray addObject:line];
    return [lineArray componentsJoinedByString:@"\n"];
}

@end
