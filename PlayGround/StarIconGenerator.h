//
//  StarIconGenerator.h
//  lab_ImageGeneration
//
//  Created by Daniel on 2/10/17.
//  Copyright © 2017 Daniel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {YELLOWSTAR, REDSTAR} STARSTYLE;

@interface StarIconGenerator : NSObject

@property UIColor *fillColor;
@property UIColor *outlineColor;
@property UIColor *dotColor;

@property CGSize canvasSize;
@property float starDiameter;
@property float outlineThinkness;
@property STARSTYLE starStyle;
@property BOOL isMarkerOn;
@property BOOL isDotOn;

-(UIImage*)generateIcon;
-(void)resetDefaultStyle;
@end
