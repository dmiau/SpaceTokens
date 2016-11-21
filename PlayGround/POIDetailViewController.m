//
//  POIDetailViewController.m
//  SpaceBar
//
//  Created by dmiau on 9/2/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "POIDetailViewController.h"

@implementation POIDetailViewController

-(void)viewWillAppear:(BOOL)animated{
    self.nameOutlet.text = self.spatialEntity.name;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.nameOutlet resignFirstResponder];
    self.spatialEntity.name = self.nameOutlet.text;
    return YES;
}

@end
