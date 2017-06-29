//
//  CustomMKMapView+Debug.m
//  NavTools
//
//  Created by dmiau on 6/25/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "CustomMKMapView+Debug.h"

@implementation CustomMKMapView (Debug)


-(void)showInformationView:(NSString*) info{
    
    // Initalize once
    if (!self.informationView){
        self.informationView = [[UITextView alloc] init];
        
        [self.informationView setUserInteractionEnabled:NO];
        
        // Set up the frame
        CGRect frame = CGRectMake(self.frame.size.width/2 - 125, 100, 250, 125);
        self.informationView.frame = frame;
        
        // Change the background color
        self.informationView.backgroundColor =
        [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7];
        
        // Round the corners
        self.informationView.layer.cornerRadius = 5;
        self.informationView.layer.masksToBounds = true;
        
        // Change the text color and size
        self.informationView.textColor = [UIColor whiteColor];
        [self.informationView setFont:[UIFont systemFontOfSize:14]];
    }
    
    self.informationView.text =  info;
    [self addSubview:self.informationView];
    
//    // Fad the dialog after some time delay
//    static NSTimer *fadingTimer;
//    fadingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
//                        target:self
//                        selector:@selector(removeInformationView)
//                        userInfo:nil
//                        repeats:NO];
}


-(void)removeInformationView{
    [self.informationView removeFromSuperview];
}

@end
