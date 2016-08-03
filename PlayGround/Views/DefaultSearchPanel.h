//
//  DefaultSearchPanel.h
//  SpaceBar
//
//  Created by dmiau on 7/19/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "topPanel.h"

@class ViewController;

@interface DefaultSearchPanel : UIView <TopPanel>
@property ViewController *rootViewController;
@property UIButton *directionButton;
-(id)initWithFrame: (CGRect)frame ViewController:(ViewController*) viewController;

-(void)addPanel;
-(void)removePanel;
@end
