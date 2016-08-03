//
//  CustomTabController.m
//  SpaceBar
//
//  Created by dmiau on 7/25/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "CustomTabController.h"


@interface CustomTabController ()

@end

@implementation CustomTabController

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
                
        // Add UINavigationBar
        UINavigationBar *navBar = [[UINavigationBar alloc] init];
        [navBar setFrame:CGRectMake(0,0,self.view.frame.size.width,60)];
        self.navigationBar = navBar;
        [self.view addSubview:navBar];
        
        // Add button to the navigation bar
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self
                                                                      action:@selector(backToMainView:)];
        UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@""];
        item.leftBarButtonItem = leftButton;
        item.hidesBackButton = YES;
        [navBar pushNavigationItem:item animated:NO];
        
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)backToMainView:(id)sender {
    if ([self.restorationIdentifier isEqualToString:@"PreferenceTabController"]){
        CATransition* transition = [CATransition animation];
        transition.duration = .25;
        transition.timingFunction =
        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromRight;
        
        [self.navigationController.view.layer addAnimation:transition
                                                    forKey:kCATransition];
        
        [self.navigationController popToRootViewControllerAnimated:NO];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
