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

#import "TokenCollectionView.h"
#import "ArrayTool.h"
#import "SetTool.h"
#import "CollectionViewCell.h"
#import "SetCollectionView.h"

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
    self.handlingBlockArray = [NSMutableArray array];
    self.isTokenDraggingEnabled = YES;
    self.isStudyModeEnabled = NO;
    self.isTokenLabelEnabled = NO;
    self.isCustomGestureRecognizerEnabled = YES;
    return self;
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
        aToken.spatialEntity.annotation.isLabelOn = isTokenLabelEnabled;
    }
}

//------------------
// Add and remove tokens
//------------------

- (SpaceToken*)addTokenFromSpatialEntity:(SpatialEntity*)spatialEntity{
    SpaceToken *aSpaceToken =
    [SpaceToken manufactureTokenForEntity:spatialEntity];
    [aSpaceToken configureAppearanceForType:DOCKED];
    
    aSpaceToken.isStudyModeEnabled = self.isStudyModeEnabled;
    aSpaceToken.isDraggable = self.isTokenDraggingEnabled;
    aSpaceToken.isCustomGestureRecognizerEnabled = self.isCustomGestureRecognizerEnabled;
        
    return aSpaceToken;
}

- (NSArray <SpaceToken*>*)getTokenArray{
    
    NSMutableArray *outArray = [NSMutableArray array];
    // Collect the tokens from TokenCollection
    for (CollectionViewCell *cell in [[TokenCollectionView sharedManager] visibleCells])
    {
        [outArray addObject: cell.spaceToken];
    }
    
    // Collect the tokens from ArrayTool
    for (CollectionViewCell *cell in [[ArrayTool sharedManager] visibleCells])
    {
        [outArray addObject: cell.spaceToken];
    }
    // Add the master token
    SpaceToken *arrayToolMaster = [[ArrayTool sharedManager] masterToken];
    if (arrayToolMaster){
        [outArray addObject: arrayToolMaster];
    }
    
    // Collect the tokens from SetTool
    for (CollectionViewCell *cell in [[SetTool sharedManager].setCollectionView visibleCells])
    {
        [outArray addObject: cell.spaceToken];
    }
    // Add the master token
    SpaceToken *setToolMaster = [[SetTool sharedManager] masterToken];
    if (setToolMaster){
        [outArray addObject: setToolMaster];
    }
    
    tokenArray = outArray;
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
