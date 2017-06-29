//
//  DMTools.m
//  NavTools
//
//  Created by dmiau on 1/31/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMTools.h"
#import "AppDelegate.h"
#import "ViewController.h"

@implementation DMTools

+(void)showAlert: (NSString*) title withMessage:(NSString*)message{
//    UIAlertView *alert = [[UIAlertView alloc]
//                initWithTitle:title
//                message:message
//                delegate:nil
//                cancelButtonTitle:@"OK"
//                                          otherButtonTitles:nil];
//    [alert show];
    
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:title
                                 message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    UIAlertAction* okButton = [UIAlertAction
                                actionWithTitle:@"OK"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                }];
//    
//    UIAlertAction* noButton = [UIAlertAction
//                               actionWithTitle:@"No, thanks"
//                               style:UIAlertActionStyleDefault
//                               handler:^(UIAlertAction * action) {
//                                   //Handle no, thanks button
//                               }];
    
    [alert addAction:okButton];

    // Get the root viewcontroller
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    UINavigationController *myNavigationController =
    app.window.rootViewController;
    
    ViewController *rootViewController =
    [myNavigationController.viewControllers objectAtIndex:0];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [rootViewController presentViewController:alert animated:YES completion:nil];
        
    }];
}

@end
