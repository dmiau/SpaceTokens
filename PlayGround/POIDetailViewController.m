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
    self.nameOutlet.text = self.poi.name;
}

- (IBAction)doneAction:(id)sender {
    [self.nameOutlet resignFirstResponder];
    self.poi.name = self.nameOutlet.text;
}
@end
