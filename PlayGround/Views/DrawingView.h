//
//  DrawingView.h
//  SpaceBar
//
//  Created by Daniel on 12/28/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawingView : UIView{
    NSMutableArray <UIBezierPath*> *bezierPathArray;
    NSMutableArray *touchPointArray;
    BOOL isArea;

    UIButton *clearButton;
}

-(void)viewWillAppear;
-(void)viewWillDisappear;

@end
