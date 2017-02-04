//
//  SearchPanelView+Actions.h
//  SpaceBar
//
//  Created by dmiau on 12/12/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SearchPanelView.h"

@interface SearchPanelView (Actions)
-(void)initDrawingButton;
-(void)customTouchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
-(void)customTouchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
-(void)customTouchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
@end
