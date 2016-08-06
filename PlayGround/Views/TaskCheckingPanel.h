//
//  TaskCheckingPanel.h
//  SpaceBar
//
//  Created by dmiau on 8/5/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "topPanel.h"

@class ViewController;

@interface TaskCheckingPanel : UIView <TopPanel>

@property ViewController *rootViewController;

@end
