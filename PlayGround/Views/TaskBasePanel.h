//
//  TaskBasePanel.h
//  SpaceBar
//
//  Created by dmiau on 8/7/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "topPanel.h"

@class ViewController;

@interface TaskBasePanel : UIView <TopPanel>

@property ViewController *rootViewController;

@property (weak, nonatomic) IBOutlet UILabel *counterOutlet;

@property (weak, nonatomic) IBOutlet UITextView *instructionsOutlet;


+(id)sharedManager;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControlOutlet;
- (IBAction)segmentControlAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *nextButtonOutlet;
- (IBAction)nextButtonAction:(id)sender;

@end
