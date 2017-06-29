//
//  SnapshotChecking.m
//  NavTools
//
//  Created by Daniel on 8/6/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SnapshotChecking.h"
#import "AppDelegate.h"
#import "ViewController.h"

@implementation SnapshotChecking{
    
}

- (id)init{
    self = [super init];
    if (self){
        //-------------------
        // Set the rootViewController
        //-------------------
        AppDelegate *app = [[UIApplication sharedApplication] delegate];
        
        UINavigationController *myNavigationController =
        app.window.rootViewController;
        self.rootViewController = [myNavigationController.viewControllers objectAtIndex:0];
        
    }
    return self;
}


- (void)setup{
    
    // Position the map to the initial condition
    
    
    // Configured SpaceToken appropriately, based on the conditions
    
    
    // Turn off routes
    
//    [self.rootViewController.mainViewManager showPanelWithType:TASKCHECKING];
    
    // Start the timer
}

- (void)cleanup{
    
}
@end
