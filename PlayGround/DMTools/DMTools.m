//
//  DMTools.m
//  SpaceBar
//
//  Created by dmiau on 1/31/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMTools.h"

@implementation DMTools

+(void)showAlert: (NSString*) title withMessage:(NSString*)message{
    UIAlertView *alert = [[UIAlertView alloc]
                initWithTitle:title
                message:message
                delegate:nil
                cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
