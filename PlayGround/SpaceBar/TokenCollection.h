//
//  TokenCollection.h
//  SpaceBar
//
//  Created by dmiau on 11/20/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SpatialEntity;
@class SpaceToken;

//---------------------------
// TokenCollection is a convenient structure which holds
// references to all the SpaceTokens on the dock
//---------------------------
@interface TokenCollection : NSObject{
    NSMutableArray <SpaceToken*> *tokenArray;
}

+ (TokenCollection*)sharedManager;

//At the moment there are two kinds of structures: TokenCollectionView and ArrayTool

// Common methods to add/remove tokens
// This is necessary because the study needs to do some special setups for the tokens


- (NSArray <SpaceToken*>*)getTokenArray;

- (SpaceToken*)addTokenFromSpatialEntity:(SpatialEntity*)spatialEntity;

// Operations to set the properties of all the SpaceTokens
@property BOOL isStudyModeEnabled;
@property BOOL isTokenDraggingEnabled; // Control whether SpaceTokens can be dragged or not
@property BOOL isTokenLabelEnabled;
@property BOOL isCustomGestureRecognizerEnabled;

@end
