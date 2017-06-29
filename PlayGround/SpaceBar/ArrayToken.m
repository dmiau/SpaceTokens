//
//  ArrayToken.m
//  NavTools
//
//  Created by Daniel on 1/3/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "ArrayToken.h"

#define ARRAY_TOKEN_WIDTH 60
#define ARRAY_TOKEN_HEIGHT 37

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
    [self setBackgroundColor:[UIColor grayColor]];
    self.frame = CGRectMake(0, 0, ARRAY_TOKEN_WIDTH, ARRAY_TOKEN_HEIGHT);

    return self;
}

+(CGSize)getSize{
    return CGSizeMake(ARRAY_TOKEN_WIDTH, ARRAY_TOKEN_HEIGHT);
}
@end
