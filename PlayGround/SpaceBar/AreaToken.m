//
//  AreaToken.m
//  NavTools
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
    [self restoreDefaultStyle];    
    return self;
}


- (void)restoreDefaultStyle{
    UIImage *areaIcon = [UIImage imageNamed:@"areaIcon"];
    
    [self setBackgroundColor:[UIColor grayColor]];
    [self setBackgroundImage:areaIcon forState:UIControlStateNormal];
    
    //UIEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right);
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    if ([self.spatialEntity.name length] > 6){
        self.titleLabel.numberOfLines = 2;
    }
}

@end
