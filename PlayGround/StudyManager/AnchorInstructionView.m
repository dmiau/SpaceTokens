//
//  AnchorInstructionView.m
//  NavTools
//
//  Created by Daniel on 12/21/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "AnchorInstructionView.h"
#import "SnapshotAnchorPlus.h"
#import "AppDelegate.h"
#import "NavTools.h"

@implementation AnchorInstructionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)prepareInstruction:(SnapshotAnchorPlus*) snapShotAnchor{
    mySnapShotAnchor = snapShotAnchor;
    
    //-----------------------
    // Populate the instructions
    //-----------------------
    self.instructionTextField.text = snapShotAnchor.instructions;
    
    //--------------------
    // Modify the instruction background if it is a demo
    //--------------------
    if ([snapShotAnchor.name rangeOfString:@"demo"].location == NSNotFound) {
        // Real task
        [self.demoBanner setHidden:YES];
    } else {
        // Demo
        [self.demoBanner setHidden:NO];
    }
    
}

- (void)showInstruction{
    // Add the instruction panel to the current view
    
    //-------------------
    // Set the rootViewController
    //-------------------
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    UINavigationController *myNavigationController =
    app.window.rootViewController;
    UIViewController *rootViewController = [myNavigationController.viewControllers objectAtIndex:0];
    
    // Adjust the size of the view
    self.frame = rootViewController.view.frame;
    
    // Need to put the instruction view in front (from the main thread)
    // to cover SnapTokenCollectionView
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [rootViewController.view addSubview:self];
        [rootViewController.view bringSubviewToFront:self];
    }];
    
}

- (IBAction)okTapped:(id)sender {
    [self removeFromSuperview];
    // Start the timer
    [mySnapShotAnchor.record start];
}
@end

