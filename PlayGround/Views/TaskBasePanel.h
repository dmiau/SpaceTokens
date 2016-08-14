//
//  TaskBasePanel.h
//  SpaceBar
//
//  Created by dmiau on 8/7/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "topPanel.h"
#import "../StudyManager/GameManager.h"

@class ViewController;

@interface TaskBasePanel : UIView <TopPanel>

@property ViewController *rootViewController;

- (void)configureForSnapshot:(id <SnapshotProtocol>) snapshot;






@end
