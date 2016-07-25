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

- (IBAction)mapStyleSegmentControl:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapSegmentControl;

@end
