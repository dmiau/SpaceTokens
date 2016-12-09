//
//  TokenCollectionView.m
//  lab_CollectionView
//
//  Created by dmiau on 12/4/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "TokenCollectionView.h"
#import "CollectionViewCell.h"

NSString *kDetailedViewControllerID = @"DetailView";    // view controller storyboard id
NSString *CellID = @"cellID";                          // UICollectionViewCell storyboard id

@implementation TokenCollectionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id) initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    self = [super initWithFrame:frame collectionViewLayout:layout];

    if (self){
        [self setBackgroundColor:[UIColor clearColor]];
        
        self.tokenWidth = 0;
        
        // Register the cell class
        //http://stackoverflow.com/questions/15184968/uicollectionview-adding-uicollectioncell
        [self registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:CellID];
        
        // Enable multiple selection
        [self setAllowsMultipleSelection:YES];
        
        //        self.view = self.collectionView;
        // Add a long-press gesture recognizer
        UILongPressGestureRecognizer *lpgr =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongGesture:)];
        [self addGestureRecognizer:lpgr];
        
        self.delegate = self;
        self.dataSource = self;
        
    }
    

    return self;
}

- (void)handleLongGesture:(UILongPressGestureRecognizer*) gesture{
    CGPoint p = [gesture locationInView:self];
    NSIndexPath *indexPath = [self indexPathForItemAtPoint:p];
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            if (indexPath){
                [self beginInteractiveMovementForItemAtIndexPath:indexPath];
            }
            break;
        case UIGestureRecognizerStateChanged:
            if (gesture.view){
                [self updateInteractiveMovementTargetPosition:[gesture locationInView:gesture.view]];
            }
            break;
        case UIGestureRecognizerStateEnded:
            [self endInteractiveMovement];
            break;
        default:
            [self cancelInteractiveMovement];
            break;
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // UIView will be "transparent" for touch events if we return NO
    return (point.x > self.frame.size.width - self.tokenWidth);
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    //#warning Incomplete implementation, return the number of sections
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 30;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell
    
    // we're going to use a custom UICollectionViewCell, which will hold an image and its label
    //
    CollectionViewCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:CellID forIndexPath:indexPath];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(60, 30);
}

-(void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    // move your data order
    NSLog(@"Item moved.");
}

@end
