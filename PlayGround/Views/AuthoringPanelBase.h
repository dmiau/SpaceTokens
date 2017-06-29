//
//  AuthoringPanelBase.h
//  NavTools
//
//  Created by Daniel on 11/28/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskBasePanel.h"
#import "topPanel.h"
#import "SnapshotProtocol.h"

@class ViewController;
@class SettingsButton;

@interface AuthoringPanelBase : UIView <TopPanel, UITextFieldDelegate>{
    SettingsButton *settingsButton;
    

    
    CGRect targetRectBox;
    CAShapeLayer *authoringVisualAidLayer;
    
    // textSink (to capture the text for SpaceToken and the instructions)
    id textSinkObject;
}


@property ViewController *rootViewController;
@property BOOL isAuthoringVisualAidOn;
@property Snapshot *snapshot;

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
