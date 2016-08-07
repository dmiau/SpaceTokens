//
//  SearchPanel.m
//  SpaceBar
//
//  Created by dmiau on 7/19/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SearchPanel.h"
#import "AppDelegate.h"
#import "ViewController.h"

@implementation SearchPanel

- (id)initWithFrame:(CGRect)frame ViewController:(ViewController*) viewController{
    
    self = [super initWithFrame:frame];
    if (self){
        
        self.rootViewController = viewController;
        // set up the color of the view
        [self setBackgroundColor:[UIColor colorWithRed: 0.97 green:0.97 blue:0.97
                                                 alpha:1.0]];
        
        
        [self initPreferenceButton];
        [self initDirectionButton];
    }
    
    return self;
}

- (void)initPreferenceButton{
    // add a button to access the preference panel
    UIButton*  preferenceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    preferenceButton.frame =
    CGRectMake(self.frame.size.width*0.05, self.frame.size.height*0.5, 60, 20);
    [preferenceButton setTitle:@"Pref." forState:UIControlStateNormal];
    preferenceButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [preferenceButton setBackgroundColor:[UIColor grayColor]];
    [preferenceButton addTarget:self action:@selector(preferenceButtonAction)
               forControlEvents:UIControlEventTouchDown];
    
    // add drop shadow
    //            self.layer.cornerRadius = 8.0f;
    preferenceButton.layer.masksToBounds = NO;
    //            self.layer.borderWidth = 1.0f;
    
    preferenceButton.layer.shadowColor = [UIColor grayColor].CGColor;
    preferenceButton.layer.shadowOpacity = 0.8;
    preferenceButton.layer.shadowRadius = 12;
    preferenceButton.layer.shadowOffset = CGSizeMake(12.0f, 12.0f);
    [self addSubview:preferenceButton];
    
    
    // add a button to access the data panel
    UIButton*  dataButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dataButton.frame =
    CGRectMake(self.frame.size.width*0.8, self.frame.size.height*0.5, 60, 20);
    [dataButton setTitle:@"Data" forState:UIControlStateNormal];
    dataButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [dataButton setBackgroundColor:[UIColor grayColor]];
    [dataButton addTarget:self action:@selector(dataButtonAction)
         forControlEvents:UIControlEventTouchDown];
    [self addSubview:dataButton];
}

- (void)initDirectionButton{
    //------------------
    // Add a direction button for testing
    //------------------
    UIButton*  directionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    directionButton.frame = CGRectMake(0, 0, 60, 20);
    [directionButton setTitle:@"Direction" forState:UIControlStateNormal];
    directionButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [directionButton setBackgroundColor:[UIColor grayColor]];
    [directionButton addTarget:self.rootViewController action:@selector(directionButtonAction)
              forControlEvents:UIControlEventTouchDown];
    
    // add drop shadow
    //            self.layer.cornerRadius = 8.0f;
    directionButton.layer.masksToBounds = NO;
    //            self.layer.borderWidth = 1.0f;
    
    directionButton.layer.shadowColor = [UIColor grayColor].CGColor;
    directionButton.layer.shadowOpacity = 0.8;
    directionButton.layer.shadowRadius = 12;
    directionButton.layer.shadowOffset = CGSizeMake(12.0f, 12.0f);
    self.directionButton = directionButton;
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

- (void)dataButtonAction{
    //-------------------
    // Set the rootViewController
    //-------------------
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    UINavigationController *myNavigationController =
    app.window.rootViewController;
    
    ViewController *rootViewController = [myNavigationController.viewControllers objectAtIndex:0];
    
    [rootViewController performSegueWithIdentifier:@"DataSegue"
                                            sender:nil];
}

//----------------------
// Add and remove the panel
//----------------------
-(void)addPanel{
    
    [self.rootViewController.view addSubview:self];
    [self.rootViewController removeRoute];
    [self.rootViewController.spaceBar
     addSpaceTokensFromPOIArray: self.rootViewController.poiDatabase.poiArray];
    
    self.rootViewController.spaceBar.spaceBarMode = TOKENONLY;
    
    // Add the direction button
    float width = self.rootViewController.mapView.frame.size.width;
    float height = self.rootViewController.mapView.frame.size.height;
    
    self.directionButton.frame = CGRectMake(width*0.1, height*0.9, 60, 20);
    [self.rootViewController.mapView addSubview:self.directionButton];
    
}

-(void)removePanel{
    // Remove the direction button
    [self.directionButton removeFromSuperview];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
