//
//  AuthoringPanel.h
//  SpaceBar
//
//  Created by dmiau on 9/9/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskBasePanel.h"
#import "topPanel.h"

@class ViewController;

@interface AuthoringPanel : UIView <TopPanel>

@property ViewController *rootViewController;
@property BOOL isAuthoringVisualAidOn;

// Initialization
+(id)sharedManager;

// Interface action related methods
- (IBAction)taskTypeAction:(id)sender;
- (IBAction)startEndAction:(id)sender;
- (IBAction)captureAction:(id)sender;
- (IBAction)addAction:(id)sender;


@end
