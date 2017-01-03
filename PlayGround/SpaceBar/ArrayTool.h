//
//  ArrayTool.h
//  SpaceBar
//
//  Created by Daniel on 1/1/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SpatialEntity;
@class ArrayEntity;
@class SpaceToken;

@interface ArrayTool : UICollectionView <UICollectionViewDelegate, UICollectionViewDataSource>

@property double tokenWidth; // this parameter is also used to decide the hitTest area

@property BOOL isVisible;

@property ArrayEntity *arrayEntity;

+(id)sharedManager;

-(void)addItemFromBottom:(SpatialEntity*)anEntity;

-(void)insertTokenToArrayTool: (SpaceToken*) token;

-(void)setTopAlignmentOffset:(int)offSet;

// This decide whether an achor is in the insertion zone or not
-(BOOL)isTokenInInsertionZone:(SpaceToken*)spaceToken;

@end
