//
//  SnapshotDetailViewController.m
//  SpaceBar
//
//  Created by dmiau on 9/12/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SnapshotDetailViewController.h"

@implementation SnapshotDetailViewController

-(void)viewWillAppear:(BOOL)animated{
    self.nameOutlet.text = self.snapshot.name;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.nameOutlet resignFirstResponder];
    self.snapshot.name = self.nameOutlet.text;
    return YES;
}

@end
