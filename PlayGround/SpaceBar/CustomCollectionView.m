//
//  CustomCollectionView.m
//  SpaceBar
//
//  Created by dmiau on 12/7/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "CustomCollectionView.h"

@implementation CustomCollectionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.tokenWidth = 0;
    }
    return self;
}


- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // UIView will be "transparent" for touch events if we return NO
    return (point.x > self.frame.size.width - self.tokenWidth);
}

@end
