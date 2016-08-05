//
//  circleCheckingPanel.h
//  SpaceBar
//
//  Created by dmiau on 8/5/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "topPanel.h"

@class ViewController;

@interface CircleCheckingPanel : UIView <TopPanel>
@property ViewController *rootViewController;

-(id)initWithFrame: (CGRect)frame ViewController:(ViewController*) viewController;

-(void)addPanel;
-(void)removePanel;
@end
