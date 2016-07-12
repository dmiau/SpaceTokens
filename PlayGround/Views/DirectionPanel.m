//
//  DirectionPanel.m
//  SpaceBar
//
//  Created by dmiau on 7/12/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "DirectionPanel.h"

@implementation DirectionPanel

- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self){
        
        // set up the color of the view
        [self setBackgroundColor:[UIColor blueColor]];
        
        // dismiss button
        UIButton*  dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        dismissButton.frame =
            CGRectMake(frame.size.width*0.1, frame.size.height*0.5, 60, 20);
        [dismissButton setTitle:@"Dismiss" forState:UIControlStateNormal];
        [dismissButton setBackgroundColor:[UIColor grayColor]];
        [dismissButton addTarget:self action:@selector(dismissButtonAction)
                  forControlEvents:UIControlEventTouchDown];
        
        // add drop shadow
        //            self.layer.cornerRadius = 8.0f;
        dismissButton.layer.masksToBounds = NO;
        //            self.layer.borderWidth = 1.0f;
        
        dismissButton.layer.shadowColor = [UIColor grayColor].CGColor;
        dismissButton.layer.shadowOpacity = 0.8;
        dismissButton.layer.shadowRadius = 12;
        dismissButton.layer.shadowOffset = CGSizeMake(12.0f, 12.0f);
        [self addSubview:dismissButton];
    }
    
    return self;
}


- (void)dismissButtonAction{
    [self removeFromSuperview];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
