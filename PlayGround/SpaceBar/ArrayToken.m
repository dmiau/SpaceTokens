//
//  ArrayToken.m
//  SpaceBar
//
//  Created by Daniel on 1/3/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "ArrayToken.h"

@implementation ArrayToken

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id) init{
    self = [super init];
    
    // Change the color to orange
    [self setBackgroundColor:[[UIColor greenColor] colorWithAlphaComponent:0.5]];
    
    return self;
}

@end
