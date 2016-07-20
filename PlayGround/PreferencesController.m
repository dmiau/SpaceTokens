//
//  PreferencesController.m
//  SpaceBar
//
//  Created by Daniel on 7/18/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "PreferencesController.h"
#import "AppDelegate.h"

@implementation PreferencesController

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
        
        // Connect to the parent view controller to update its
        // properties directly
        
        //-------------------
        // Set the rootViewController
        //-------------------
        AppDelegate *app = [[UIApplication sharedApplication] delegate];
        
        self.rootViewController = (ViewController*) app.window.rootViewController;
    }
    return self;
}

@end
