//
//  SetTool.h
//  SpaceBar
//
//  Created by Daniel on 1/9/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SpaceToken;
@class ArrayEntity;
@class MiniMapView;

@interface SetTool : UIView

@property BOOL isVisible;
@property MiniMapView *miniMapView;
@property ArrayEntity *arrayEntity;

+(id)sharedManager;

-(BOOL)isTouchInMasterTokenZone:(UITouch*)touch;
-(void)insertMaster:(SpaceToken*) token;
-(BOOL)isTouchInInsertionZone:(UITouch*)touch;

-(void)insertToken: (SpaceToken*) token;
-(void)removeToken: (SpaceToken*) token;
@end
