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
#import "UIImage+tools.h"
#import "EntityDatabase.h"
#import "CollectionInformationSheet.h"

#define INITIAL_HEIGHT 50

@implementation MapInformationSheet


-(void)awakeFromNib{
    // Add shadow
    // http://stackoverflow.com/questions/805872/how-do-i-draw-a-shadow-under-a-uiview
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(0, -1);
    self.layer.shadowRadius = 3;
    self.layer.shadowOpacity = 0.4;
}

-(void)addSheet{
    // Add the sheet to the top view
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    UINavigationController *myNavigationController =
    app.window.rootViewController;
    ViewController *rootViewController = [myNavigationController.viewControllers objectAtIndex:0];
    
    CGRect rootViewFrame = rootViewController.view.frame;
    
    if ([self isMemberOfClass:[CollectionInformationSheet class]]){
        CGRect frame = CGRectMake(0, rootViewFrame.size.height-INITIAL_HEIGHT - 30,
                                  rootViewFrame.size.width, self.frame.size.height);
        self.frame = frame;
    }else{
        CGRect frame = CGRectMake(0, rootViewFrame.size.height-INITIAL_HEIGHT,
                                  rootViewFrame.size.width, self.frame.size.height);
        self.frame = frame;
    }
    


    [rootViewController.view addSubview:self];
    
    // Need to update the placement of UI elements (e.g., TokenCollectionView, ArrayTool, etc.)
    [rootViewController updateUIPlacement];
}

-(void)addSheetForEntity:(SpatialEntity*)entity{
    self.spatialEntity = entity;
    [self addSheet];
    [self updateSheet];
}

-(void)removeSheet{
    [self removeFromSuperview];
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    UINavigationController *myNavigationController =
    app.window.rootViewController;
    ViewController *rootViewController = [myNavigationController.viewControllers objectAtIndex:0];
    [rootViewController updateUIPlacement];
}

-(void)updateSheet{
    
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
