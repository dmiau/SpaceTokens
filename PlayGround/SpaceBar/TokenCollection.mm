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

-(SpaceToken*)findSpaceTokenFromEntity:(SpatialEntity*)entity
forStructure:(id)structure
{
    SpaceToken *outToken = nil;
    
    for (SpaceToken *aToken in tokenArray){
        if ([aToken.spatialEntity isEqual:entity]
            && [aToken.home isEqual:structure])
        {
            outToken = aToken;
            break;
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
    [tokenArray addObject:aToken];
    aToken.isStudyModeEnabled = self.isStudyModeEnabled;
    aToken.isDraggable = self.isTokenDraggingEnabled;
    aToken.isCustomGestureRecognizerEnabled = self.isCustomGestureRecognizerEnabled;
}

- (SpaceToken*)addTokenFromSpatialEntity:(SpatialEntity*)spatialEntity{
    SpaceToken *aSpaceToken =
    [SpaceToken manufactureTokenForEntity:spatialEntity] ;
    [aSpaceToken configureAppearanceForType:DOCKED];

    [self addToken:aSpaceToken];
    return aSpaceToken;
}

- (void)removeToken:(SpaceToken *)aToken{
    [tokenArray removeObject:aToken];
}

- (void)removeAllTokens{
    [tokenArray removeAllObjects];
}

- (void)removeAllTokensForStructure:(id)structure{
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"SELF.home = %@", structure];
    NSArray *filteredArray = [tokenArray filteredArrayUsingPredicate:bPredicate];
    [tokenArray removeObjectsInArray:filteredArray];
}


- (NSArray <SpaceToken*>*)getTokenArray{
    NSArray *outArray = [NSArray arrayWithArray:tokenArray];
    return outArray;
}

-(NSString*)description{
    NSMutableArray *lineArray = [NSMutableArray array];
    NSString *line = [NSString stringWithFormat:@"TokenCollection Gesture Mode: %d", self.isCustomGestureRecognizerEnabled];
    [lineArray addObject:line];
    
    [lineArray addObject:[NSString stringWithFormat:@"TokenCollection #:%lu", [tokenArray count]]];
    return [lineArray componentsJoinedByString:@"\n"];
}

@end
