//
//  PreferencesController.h
//  NavTools
//
//  Created by Daniel on 7/18/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "ViewController.h"

@interface PreferencesController : UIViewController

@property ViewController* rootViewController;

// Map mode segment control
- (IBAction)mapStyleSegmentControl:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapSegmentControl;

// Long press control
@property (weak, nonatomic) IBOutlet UISegmentedControl *longPressSegmentOutlet;
- (IBAction)longPressSegmentAction:(id)sender;

// Transportation type
@property (weak, nonatomic) IBOutlet UISegmentedControl *transportTypeOutlet;
- (IBAction)transportTypeAction:(id)sender;

// Sync map rotation
@property (weak, nonatomic) IBOutlet UISegmentedControl *syncMiniMapRotationOutlet;
- (IBAction)syncMiniMapRotationAction:(id)sender;

// App mode segment control
@property (weak, nonatomic) IBOutlet UISegmentedControl *appModeSegmentControlOutlet;
- (IBAction)appModeSegmentControl:(id)sender;


// Debug info.
@property (weak, nonatomic) IBOutlet UITextView *debugInfoOutlet;
@property (weak, nonatomic) IBOutlet UISwitch *screenCaptureSwitchOutlet;
- (IBAction)screenCaptureSwtichAction:(id)sender;

@end
