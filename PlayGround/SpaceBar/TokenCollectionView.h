//
//  TokenCollectionView.h
//  lab_CollectionView
//
//  Created by dmiau on 12/4/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SpatialEntity;

@interface TokenCollectionView : UICollectionView <UICollectionViewDelegate, UICollectionViewDataSource>

@property double tokenWidth; // this parameter is also used to decide the hitTest area

@property BOOL isVisible;

+(id)sharedManager;
- (id) initSingleton;

-(void)addItemFromBottom:(SpatialEntity*)anEntity;

-(void)setTopAlignmentOffset:(int)offSet;
@end
