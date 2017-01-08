//
//  ToolPalette.m
//  SpaceBar
//
//  Created by dmiau on 1/7/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "ToolPalette.h"
#import "DrawingView.h"

@implementation ToolPalette{
    BOOL moveMode;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    moveMode = false;
    
    return self;
}



// MARK: touch handling

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    
    CGRect moveDetectionArea = CGRectMake(0, 0, 40, 60);
    if (CGRectContainsPoint(moveDetectionArea, touchPoint)){
        moveMode = YES;
    }else{
        moveMode = NO;
    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!moveMode)
        return;
    
    CGPoint currentPoint = [[touches anyObject] locationInView:self];
    CGPoint previousPoint = [[touches anyObject] previousLocationInView:self];
    CGPoint diff = CGPointMake(currentPoint.x - previousPoint.x, currentPoint.y - previousPoint.y);
    
    // Move the view
    self.center = CGPointMake(self.center.x + diff.x, self.center.y + diff.y);
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    moveMode = NO;
}

// MARK: button actions
- (IBAction)drawTouchDown:(id)sender {
    self.drawingView.drawingModeEnabled = YES;
}

- (IBAction)drawTouchUp:(id)sender {
    self.drawingView.drawingModeEnabled = NO;
}

- (IBAction)drawCancelled:(id)sender {
    self.drawingView.drawingModeEnabled = NO;
}
@end
