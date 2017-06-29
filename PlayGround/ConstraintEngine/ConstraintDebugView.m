//
//  ConstraintDebugView.m
//  NavTools
//
//  Created by Daniel on 11/7/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "ConstraintDebugView.h"

@implementation ConstraintDebugView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/




- (IBAction)recordButtonTapped:(id)sender {
    [self.speechEngine guiRecordButtonTapped];
}

- (IBAction)dismissButtonTapped:(id)sender {
    // Remove from super view
    [self removeFromSuperview];
}
@end
