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
@class SetCollectionView;

typedef enum {SetMode, MapMode, EmptyMode} SetToolMode;

@interface SetTool : UIView
@property (weak, nonatomic) IBOutlet MiniMapView *miniMapView;
@property (weak, nonatomic) IBOutlet UIView *toolView;
@property (weak, nonatomic) IBOutlet SetCollectionView *setCollectionView;

@property SetToolMode setToolMode;

-(BOOL)isTouchInMasterTokenZone:(UITouch*)touch;
-(void)insertMaster:(SpaceToken*) token;

+(SetTool*)sharedManager;

-(BOOL)isTouchInInsertionZone:(UITouch*)touch;


@property BOOL isVisible;
@property ArrayEntity *arrayEntity;
-(void)insertToken: (SpaceToken*) token;
-(void)removeToken: (SpaceToken*) token;
- (IBAction)switchViewAction:(id)sender;

@end
