//
//  TokenCollectionView.h
//  lab_CollectionView
//
//  Created by dmiau on 12/4/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SpatialEntity;
@class ArrayEntity;
@class SpaceToken;

@interface TokenCollectionView : UICollectionView <UICollectionViewDelegate, UICollectionViewDataSource>

@property double tokenWidth; // this parameter is also used to decide the hitTest area

@property BOOL isVisible;

@property ArrayEntity *arrayEntity;

+(TokenCollectionView*)sharedManager;


-(SpaceToken*)findSpaceTokenFromEntity:(SpatialEntity*)anEntity;

-(void)addItemFromBottom:(SpatialEntity*)anEntity;

-(void)setTopAlignmentOffset:(int)offSet;

-(BOOL)isTouchInInsertionZone:(UITouch*)touch;

-(void)insertToken: (SpaceToken*) token;
-(void)removeToken: (SpaceToken*) token;
@end
