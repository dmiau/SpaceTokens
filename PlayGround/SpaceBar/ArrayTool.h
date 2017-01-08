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

-(BOOL)isTouchInMasterTokenZone:(UITouch*)touch;
-(void) insertMaster:(SpaceToken*) token;
@end
