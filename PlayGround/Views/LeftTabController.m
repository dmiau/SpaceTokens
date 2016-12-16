//
//  LeftTabController.m
//  SpaceBar
//
//  Created by Daniel on 12/15/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "LeftTabController.h"

@interface LeftTabController ()

@end

@implementation LeftTabController

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
        // Add UINavigationBar
        UINavigationBar *navBar = [[UINavigationBar alloc] init];
        [navBar setFrame:CGRectMake(0,0,self.view.frame.size.width,60)];
        self.navigationBar = navBar;
        [self.view addSubview:navBar];
        
        // Add button to the navigation bar
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                style:UIBarButtonItemStyleDone
                target:self
                action:@selector(backToMainView:)];
        UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"Back"];
        item.rightBarButtonItem = rightButton;
        item.hidesBackButton = YES;
        [navBar pushNavigationItem:item animated:NO];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backToMainView:(id)sender {
    UINavigationController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    if ([self.restorationIdentifier isEqualToString:@"PreferenceTabController"]){
        CATransition* transition = [CATransition animation];
        transition.duration = .40;
        transition.timingFunction =
        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromRight;
        

        [rootViewController.view.layer addAnimation:transition
                                                    forKey:kCATransition];
        
        [rootViewController popToRootViewControllerAnimated:NO];
    }else{
        [rootViewController popViewControllerAnimated:YES];
    }
}
@end
