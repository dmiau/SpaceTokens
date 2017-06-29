//
//  ToolPalette.h
//  NavTools
//
//  Created by dmiau on 1/7/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DrawingView;

@interface ToolPalette : UIView
@property DrawingView* drawingView;


- (IBAction)drawTouchDown:(id)sender;
- (IBAction)drawTouchUp:(id)sender;
- (IBAction)drawCancelled:(id)sender;


@end
