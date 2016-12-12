//
//  PathToken.m
//  SpaceBar
//
//  Created by dmiau on 11/16/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "PathToken.h"

@implementation PathToken

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
    [self setBackgroundColor:[UIColor orangeColor]];
    
    return self;
}

@end
