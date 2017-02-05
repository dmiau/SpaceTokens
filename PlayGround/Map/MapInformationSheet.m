//
//  MapInformationSheet.m
//  SpaceBar
//
//  Created by Daniel on 2/1/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "MapInformationSheet.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

#define INITIAL_HEIGHT 60

@implementation MapInformationSheet


-(void)awakeFromNib{
    // Add shadow
    // http://stackoverflow.com/questions/805872/how-do-i-draw-a-shadow-under-a-uiview
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(0, -1);
    self.layer.shadowRadius = 3;
    self.layer.shadowOpacity = 0.4;
    
    // Initialize the object
    self.titleOutlet.delegate = self;
}

-(void)addSheet{
    // Add the sheet to the top view
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    UINavigationController *myNavigationController =
    app.window.rootViewController;
    ViewController *rootViewController = [myNavigationController.viewControllers objectAtIndex:0];
    
    CGRect rootViewFrame = rootViewController.view.frame;
    CGRect frame = CGRectMake(0, rootViewFrame.size.height-INITIAL_HEIGHT,
                              rootViewFrame.size.width, self.frame.size.height);
    self.frame = frame;

    [rootViewController.view addSubview:self];
    
    // Need to update the placement of UI elements (e.g., TokenCollectionView, ArrayTool, etc.)
    [rootViewController updateUIPlacement];
}

-(void)addSheetForEntity:(SpatialEntity*)entity{
    self.spatialEntity = entity;
    [self addSheet];
}

-(void)removeSheet{
    [self removeFromSuperview];
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    UINavigationController *myNavigationController =
    app.window.rootViewController;
    ViewController *rootViewController = [myNavigationController.viewControllers objectAtIndex:0];
    [rootViewController updateUIPlacement];
}


// MARK: Setters
//-------------------------------------
-(void)setSpatialEntity:(SpatialEntity *)spatialEntity{
    _spatialEntity = spatialEntity;
    self.titleOutlet.text = spatialEntity.name;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

// MARK: keyboard input
//-------------------------------------

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    CGRect superFrame = self.superview.frame;
    
    CGRect frame = CGRectMake(0, superFrame.size.height/2,
                              self.frame.size.width, self.frame.size.height);
    self.frame = frame;
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //---------------
    // Rename a token
    //---------------
    self.spatialEntity.name = self.titleOutlet.text;
    
    // Find all the tokens with the same spatial entity
    for (SpaceToken *token in [[TokenCollection sharedManager] getTokenArray]){
        if (token.spatialEntity == self.spatialEntity){
            [token
             setTitle: self.titleOutlet.text
             forState: UIControlStateNormal];
        }
    }
    
    [self.titleOutlet resignFirstResponder];
    
    // Need to shift the panel down
    CGRect superFrame = self.superview.frame;
    CGRect frame = CGRectMake(0, superFrame.size.height - INITIAL_HEIGHT,
                              self.frame.size.width, self.frame.size.height);
    self.frame = frame;

    return YES;
}


// MARK: view movement
//-------------------------------------
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    
    CGPoint currentPoint = [[touches anyObject] locationInView:self];
    CGPoint previousPoint = [[touches anyObject] previousLocationInView:self];
    CGPoint diff = CGPointMake(currentPoint.x - previousPoint.x, currentPoint.y - previousPoint.y);
    
    // Move the view
    CGPoint newCenter = CGPointMake(self.center.x, self.center.y + diff.y);
    float topY = newCenter.y - self.frame.size.height/2;
    if ( topY > self.superview.frame.size.height - self.frame.size.height
        && topY < self.superview.frame.size.height - INITIAL_HEIGHT){
        self.center = newCenter;
    }
}


@end
