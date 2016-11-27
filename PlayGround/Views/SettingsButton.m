//
//  SettingsButton.m
//  SpaceBar
//
//  Created by dmiau on 8/5/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SettingsButton.h"
#import "AppDelegate.h"
#import "ViewController.h"

@implementation SettingsButton

- (id)init{
    self = [super init];
    if (self){
        [self initPreferenceButton];
    }
    return self;
}

- (void)initPreferenceButton{
    ViewController *rootViewController = [ViewController sharedManager];
    self.frame = CGRectMake(rootViewController.view.frame.size.width-30, 15, 30, 30);
    [self setTitle:@"S." forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self setBackgroundColor:[UIColor grayColor]];
    [self addTarget:self action:@selector(preferenceButtonAction)
               forControlEvents:UIControlEventTouchDown];
    
    // add drop shadow
    //            self.layer.cornerRadius = 8.0f;
    self.layer.masksToBounds = NO;
    //            self.layer.borderWidth = 1.0f;
    
    self.layer.shadowColor = [UIColor grayColor].CGColor;
    self.layer.shadowOpacity = 0.8;
    self.layer.shadowRadius = 12;
    self.layer.shadowOffset = CGSizeMake(12.0f, 12.0f);
}


- (void)preferenceButtonAction{
    //-------------------
    // Set the rootViewController
    //-------------------
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    UINavigationController *myNavigationController =
    app.window.rootViewController;
    
    //    ViewController *rootViewController =
    //    [myNavigationController.viewControllers objectAtIndex:0];
    //
    //    [rootViewController performSegueWithIdentifier:@"PreferencesSegue"
    //                                            sender:nil];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *destinationController = (UIViewController *)[sb instantiateViewControllerWithIdentifier:@"PreferenceTabController"];
    CATransition* transition = [CATransition animation];
    transition.duration = .25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    
    [myNavigationController.view.layer addAnimation:transition
                                             forKey:kCATransition];
    
    [myNavigationController pushViewController:destinationController animated:NO];
    
}
@end
