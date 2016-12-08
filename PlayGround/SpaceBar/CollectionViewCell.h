//
//  CollectionViewCell.h
//  lab_CollectionView
//
//  Created by dmiau on 12/5/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpaceToken.h"

@interface CollectionViewCell : UICollectionViewCell{

}

@property SpaceToken *spaceToken;

- (void)configureSpaceTokenFromEntity:(SpatialEntity *)spatialEntity;

@end
