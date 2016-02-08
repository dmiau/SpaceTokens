//
//  tester.m
//  SpaceBar
//
//  Created by dmiau on 2/8/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "tester.h"
#import "Tools.h"
#import <UIKit/UIKit.h>

@implementation Tester

- (void)runTests{
    // test QueueAddition
    
    NSMutableArray *myArray = [[NSMutableArray alloc] init];
    UIButton *button1 = [myArray Queue_dequeueReusableObjOfClass:@"UIButton"];
    [button1 setTitle:@"Button 1" forState:UIControlStateNormal];

    UIButton *button2 = [myArray Queue_dequeueReusableObjOfClass:@"UIButton"];
    
    UIView *myView = [[UIView alloc] init];
    [myView addSubview:button1];
    
    UIButton *button3 = [myArray Queue_dequeueReusableObjOfClass:@"UIButton"];
    
    NSLog(@"Done!");

}

@end
