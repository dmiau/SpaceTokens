//
//  DrawingView.h
//  SpaceBar
//
//  Created by Daniel on 12/28/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawingView : UIView{
    UIBezierPath *path;
}

-(void)viewWillAppear;
-(void)viewWillDisappear;

@end
