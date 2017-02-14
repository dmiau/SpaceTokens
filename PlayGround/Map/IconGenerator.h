//
//  IconGenerator.h
//  SpaceBar
//
//  Created by Daniel on 2/13/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IconGenerator : NSObject

@property UIColor *fillColor;
@property UIColor *outlineColor;
@property UIColor *dotColor;

@property CGSize canvasSize;
@property float iconDiameter;
@property float outlineThinkness;

@property BOOL isMarkerOn;
@property BOOL isDotOn;

-(UIImage*)generateIcon;
-(void)resetDefaultStyle;

@end
