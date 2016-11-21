//
//  ConnectionTool.h
//  SpaceBar
//
//  Created by dmiau on 11/18/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SpaceToken;
@class SpaceBar;

@interface ConnectionTool : UIButton

@property BOOL isLineLayerOn;
@property BOOL isDraggable;


- (void)attachToSpaceToken:(SpaceToken*) spaceToken;

@end
