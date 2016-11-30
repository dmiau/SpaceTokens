//
//  AuthoringPanelBase.h
//  SpaceBar
//
//  Created by Daniel on 11/28/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskBasePanel.h"
#import "topPanel.h"

@class ViewController;
@class SettingsButton;

@interface AuthoringPanelBase : UIView <TopPanel, UITextFieldDelegate>{
    SettingsButton *settingsButton;
    
    Snapshot *snapShot;
    NSMutableArray *spaceTokenPOIsArray;
    NSMutableArray *highlightedPOIsArray;
    NSMutableArray *targetedPOIsArray;
    
    CGRect targetRectBox;
    CAShapeLayer *authoringVisualAidLayer;
    
    // textSink (to capture the text for SpaceToken and the instructions)
    id textSinkObject;
}


@property ViewController *rootViewController;
@property BOOL isAuthoringVisualAidOn;

//-------------
// TopPanel required methods
//-------------
- (void)addPanel;
- (void)removePanel;


//-------------
// Some common tools
//-------------
-(void)captureInitialMap;
-(void)captureEndingMap;
-(void)resetInterface;

@end
