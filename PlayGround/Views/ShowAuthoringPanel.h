//
//  ShowAuthoringPanel.h
//  NavTools
//
//  Created by Daniel on 11/29/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "AuthoringPanelBase.h"

@interface ShowAuthoringPanel : AuthoringPanelBase


@property (weak, nonatomic) IBOutlet UIButton *captureStartCondOutlet;
@property (weak, nonatomic) IBOutlet UISegmentedControl *poiTypeSegmentOutlet;

- (IBAction)addAction:(id)sender;
- (IBAction)resetAction:(id)sender;
- (IBAction)poiTypeSegmentAction:(id)sender;

- (IBAction)taskTypeAction:(id)sender;

- (IBAction)captureStartAction:(id)sender;

@end
