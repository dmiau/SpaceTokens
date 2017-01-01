//
//  AreaToken.m
//  SpaceBar
//
//  Created by Daniel on 12/30/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "AreaToken.h"

@implementation AreaToken

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
    [self setBackgroundColor:[[UIColor redColor] colorWithAlphaComponent:0.5]];
    
    return self;
}

@end
