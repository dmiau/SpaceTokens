//
//  DiskGenerator.h
//  SpaceBar
//
//  Created by dmiau on 2/12/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {REDDISK, GRAYDISK} DISKSTYLE;

@interface DiskGenerator : NSObject
@property NSMutableArray *fillColorArray;
@property UIColor *outlineColor;

@property CGSize canvasSize;
@property float diskDiameter;
@property float outlineThinkness;
@property DISKSTYLE diskStyle;
@property BOOL isMarkerOn;
@property BOOL isDotOn;

-(UIImage*)generateIcon;
-(void)resetDefaultStyle;

@end
