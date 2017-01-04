//
//  ArrayTool.h
//  SpaceBar
//
//  Created by Daniel on 1/1/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TokenCollectionView.h"

@class SpatialEntity;
@class ArrayEntity;
@class SpaceToken;

@interface ArrayTool : TokenCollectionView <UICollectionViewDelegate, UICollectionViewDataSource>

// This decide whether an achor is in the insertion zone or not
-(BOOL)isTouchInInsertionZone:(UITouch*)touch;

@end
