//
//  ArrayTool.h
//  NavTools
//
//  Created by Daniel on 1/1/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TokenCollectionView.h"

@class SpatialEntity;
@class ArrayEntity;
@class PathToken;
@class Route;
typedef enum {ArrayMode, PathMode} ArrayToolMode;

@interface ArrayTool : TokenCollectionView <UICollectionViewDelegate, UICollectionViewDataSource>

+(ArrayTool*)sharedManager;
+(void)resetSharedInstace; //this is to reset the shared instance

@property Route* arrayEntity;

@property PathToken *masterToken;
@property ArrayToolMode arrayToolMode;

-(void)resetTool;
@end
