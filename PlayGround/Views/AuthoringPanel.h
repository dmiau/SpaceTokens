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
@class SettingsButton;

@interface AuthoringPanel : UIView <TopPanel, UITextFieldDelegate>{
    SettingsButton *settingsButton;
    Snapshot *snapShot;
    NSMutableArray *highlightedPOIsArray;
    NSMutableArray *spaceTokenPOIsArray;
    NSMutableArray *targetedPOIsArray;
    
    CGRect targetRectBox;
    CAShapeLayer *authoringVisualAidLayer;
    
    // Adding an UIVeiw to capture gestures
    UIView *gestureView;
    NSMutableArray *captureArray;
}

@property ViewController *rootViewController;
@property BOOL isAuthoringVisualAidOn;

// Initialization
+(id)sharedManager;


// Interface outlets
@property (weak, nonatomic) IBOutlet UISegmentedControl *taskTypeOutlet;
@property (weak, nonatomic) IBOutlet UIButton *captureStartCondOutlet;
@property (weak, nonatomic) IBOutlet UIButton *captureEndCondOutlet;
@property (weak, nonatomic) IBOutlet UITextField *instructionOutlet;
@property (weak, nonatomic) IBOutlet UIButton *highlightedPOIOutlet;
@property (weak, nonatomic) IBOutlet UIButton *spaceTokenPOIOutlet;

// Interface action related methods
- (IBAction)taskTypeAction:(id)sender;
- (IBAction)captureStartAction:(id)sender;
- (IBAction)captureEndAction:(id)sender;

- (IBAction)highlightPOIAction:(id)sender;
- (IBAction)spaceTokenPOIAction:(id)sender;

- (IBAction)instructionAction:(id)sender;

- (IBAction)resetAction:(id)sender;
- (IBAction)addAction:(id)sender;

@end
