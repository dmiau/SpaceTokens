//
//  DrawingView.h
//  NavTools
//
//  Created by Daniel on 12/28/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ToolPalette;


@interface DrawingView : UIView{
    NSMutableArray <UIBezierPath*> *bezierPathArray;
    NSMutableArray *touchPointArray;
    BOOL isArea;
    
    UIButton *clearButton;
}

@property ToolPalette *toolPalette;
@property BOOL drawingModeEnabled;

-(void)viewWillAppear;
-(void)viewWillDisappear;

@end
