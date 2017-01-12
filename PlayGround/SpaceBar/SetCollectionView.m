//
//  SetCollectionView.m
//  SpaceBar
//
//  Created by Daniel on 1/11/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "SetCollectionView.h"
#import "TokenCollection.h"
#import "ArrayEntity.h"
#import "CollectionViewCell.h"
#import "SetTool.h"

@implementation SetCollectionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    
    return self;
}

-(void)initObject{
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    // Configure the layout object
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    [self setCollectionViewLayout:layout];
    self.arrayEntity = [[ArrayEntity alloc] init];
    [self setBackgroundColor:[UIColor clearColor]];
    
    
    // Register the cell class
    //http://stackoverflow.com/questions/15184968/uicollectionview-adding-uicollectioncell
    [self registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"cellID"];
    
    // Enable multiple selection
    [self setAllowsMultipleSelection:YES];
    
//    //        self.view = self.collectionView;
//    // Add a long-press gesture recognizer
//    UILongPressGestureRecognizer *lpgr =
//    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongGesture:)];
//    [self addGestureRecognizer:lpgr];
    
    self.delegate = self;
    self.dataSource = self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    if (self.isHidden || [[self.arrayEntity getContent] count] == 0)
        return NO;
    
    // UIView will be "transparent" for touch events if we return NO
    return (CGRectContainsPoint(self.bounds, point));
}

#pragma mark <UICollectionViewDataSource>
// TODO: need to implement a viewWillAppear
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    // Reset TokenCollection
    [[TokenCollection sharedManager] removeAllTokensForStructure:self];

//
//    if ([self.arrayEntity.contentArray count]==1
//        && !masterToken)
    //    {
    //        // Insert a master token on the top
    //        [self initMasterToken];
    //    }
    //
    //    if ([self.arrayEntity.contentArray count]>=2
    //        && !pathModeButton)
    //    {
    //        // Insert a path switch on the bottom
    //        [self initPathModeSwitch];
    //    }
    //
    // Update the bound of the master token

    return [[self.arrayEntity getContent] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CollectionViewCell *cell = [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    cell.spaceToken.home = [SetTool sharedManager];
    
    return cell;
}

@end
