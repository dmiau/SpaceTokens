//
//  PreferencesController.h
//  SpaceBar
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
@property (weak, nonatomic) IBOutlet UISegmentedControl *miniMapOutlet;
- (IBAction)miniMapAction:(id)sender;

// App mode segment control
@property (weak, nonatomic) IBOutlet UISegmentedControl *appModeSegmentControlOutlet;
- (IBAction)appModeSegmentControl:(id)sender;

@end
