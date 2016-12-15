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
        
//        // Add UINavigationBar
//        UINavigationBar *navBar = [[UINavigationBar alloc] init];
//        [navBar setFrame:CGRectMake(0,0,self.view.frame.size.width,60)];
//        self.navigationBar = navBar;
//        [self.view addSubview:navBar];
//        
//        // Add button to the navigation bar
//        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Hello"
//                style:UIBarButtonItemStyleDone
//                target:self
//                                                                      action:@selector(backToMainView:)];
//        UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"Hello"];
//        item.rightBarButtonItem = rightButton;
//        item.hidesBackButton = YES;
//        [navBar pushNavigationItem:item animated:NO];
        
        
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
    if ([self.restorationIdentifier isEqualToString:@"PreferenceTabController"]){
        CATransition* transition = [CATransition animation];
        transition.duration = .45;
        transition.timingFunction =
        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromLeft;
        
        [self.navigationController.view.layer addAnimation:transition
                                                    forKey:kCATransition];
        
        [self.navigationController popToRootViewControllerAnimated:NO];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
