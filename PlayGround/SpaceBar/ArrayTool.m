//
//  ArrayTool.m
//  SpaceBar
//
//  Created by Daniel on 1/1/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "ArrayTool.h"

#import "CollectionViewCell.h"


#import "TokenCollection.h"
#import "CustomMKMapView.h"
#import "SpaceBar.h"

#import "ArrayEntity.h"



@implementation ArrayTool


+(id)sharedManager{
    static ArrayTool *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ArrayTool alloc] initSingleton];
    });
    
    return sharedInstance;
}

// Overwrite super's initSingleton method
- (id) initSingleton{
    // Get the map view
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    // Configure the layout object
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake
    (0, 0, 0, mapView.frame.size.width-60);
    
    
    // Initialize a collection view
    self =
    [[ArrayTool alloc] initWithFrame:mapView.frame collectionViewLayout:layout];
    
    self.tokenWidth = 60;
    [self setTopAlignmentOffset:30];
    
    return self;
}



- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // UIView will be "transparent" for touch events if we return NO
    return ((point.x < self.tokenWidth)
            &&(point.y > 0));
}




#pragma mark <UICollectionViewDataSource>

// TODO: need to implement a viewWillAppear
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if ([self.arrayEntity.contentArray count] > 12){
        [TokenCollection sharedManager].isCustomGestureRecognizerEnabled = NO;
    }else{
        [TokenCollection sharedManager].isCustomGestureRecognizerEnabled = YES;
    }
    
    return [self.arrayEntity.contentArray count];
}



// This decide whether an achor is in the insertion zone or not.
-(BOOL)isTokenInInsertionZone:(SpaceToken*)spaceToken{
    
    if (!self.isVisible)
        return NO;
    
    CGPoint tokenPoint = [spaceToken.superview convertPoint:spaceToken.center
                                           toView:self];
    if (tokenPoint.x < self.tokenWidth * 0.5){
        return YES;
    }else{
        return NO;
    }
}

@end
