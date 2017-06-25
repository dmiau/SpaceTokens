//
//  PersonToken.m
//  SpaceBar
//
//  Created by dmiau on 2/12/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "PersonToken.h"
#import "Person.h"

@implementation PersonToken

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
    UIImage *areaIcon = [UIImage imageNamed:@"personIcon"];
    
    [self setBackgroundColor:[UIColor grayColor]];
    [self setBackgroundImage:areaIcon forState:UIControlStateNormal];
    
    //UIEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right);
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 19, 0, 0)];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    if ([self.spatialEntity.name length] > 6){
        self.titleLabel.numberOfLines = 2;
    }
}

- (void)setSelected:(BOOL)selected{
    
    if ([self.spatialEntity isKindOfClass:[Person class]]){
        // A SpaceToken may be linked to a dynamic locaiton, such as a person
        Person *aPerson = (Person*)self.spatialEntity;
        
        
        if (selected){
            aPerson.updateFlag = YES;
            aPerson.annotation.pointType = YouRHere;
        }else{
            // http://stackoverflow.com/questions/14924892/nstimer-with-anonymous-function-block
            int64_t delayInSeconds = 5; // Your Game Interval as mentioned above by you
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                // Update your label here.
                aPerson.updateFlag = NO;
            });
        }
    }else{
        NSLog(@"Something is wrong...");
    }
    
    [super setSelected:selected];
}


@end
