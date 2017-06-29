//
//  SetTool.h
//  NavTools
//
//  Created by Daniel on 1/9/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SpaceToken;
@class PathToken;
@class Route;
@class MiniMapView;
@class SetCollectionView;

typedef enum {SetMode, MapMode, EmptyMode} SetToolMode;

@interface SetTool : UIView
@property (weak, nonatomic) IBOutlet MiniMapView *miniMapView;
@property (weak, nonatomic) IBOutlet UIView *toolView;
@property (weak, nonatomic) IBOutlet SetCollectionView *setCollectionView;

@property SetToolMode setToolMode;

@property PathToken *masterToken;
@property BOOL isVisible;
@property Route *arrayEntity;

+(SetTool*)sharedManager;
-(BOOL)isTouchInMasterTokenZone:(UITouch*)touch;


-(void)insertToken: (SpaceToken*) token;
-(void)removeToken: (SpaceToken*) token;
- (IBAction)switchViewAction:(id)sender;

@end
