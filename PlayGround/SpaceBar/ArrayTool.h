//
//  ArrayTool.h
//  SpaceBar
//
//  Created by Daniel on 1/1/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SpatialEntity;

@interface ArrayTool : UICollectionView <UICollectionViewDelegate, UICollectionViewDataSource>

@property double tokenWidth; // this parameter is also used to decide the hitTest area

@property BOOL isVisible;

+(id)sharedManager;
- (id) initSingleton;

-(void)addItemFromBottom:(SpatialEntity*)anEntity;

-(void)setTopAlignmentOffset:(int)offSet;

@end
