//
//  ArrayTool.m
//  SpaceBar
//
//  Created by Daniel on 1/1/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "ArrayTool.h"
#import "CustomMKMapView.h"
#import "CollectionViewCell.h"
#import "EntityDatabase.h"
#import "SpatialEntity.h"
#import "TokenCollection.h"
#import "CustomMKMapView.h"
#import "SpaceBar.h"
#import "ViewController.h"

//-------------------
// Parameters
//-------------------
#define CELL_WIDTH 60
#define CELL_HEIGHT 30

NSString *ArrayCellID = @"cellID";                          // UICollectionViewCell storyboard id


@implementation ArrayTool{
    NSMutableArray *enabledEntityArray;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

static ArrayTool *sharedInstance;

+(id)sharedManager{
    if (!sharedInstance){
        [NSException raise:@"Structure error" format:@"sharedInstance is not ready before access."];
    }
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
    
    sharedInstance = self;
    return self;
}


- (id) initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    
    // Initialize instance variable
    enabledEntityArray = [[NSMutableArray alloc] init];
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    self.tokenWidth = CELL_WIDTH;
    
    // Register the cell class
    //http://stackoverflow.com/questions/15184968/uicollectionview-adding-uicollectioncell
    [self registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:ArrayCellID];
    
    // Enable multiple selection
    [self setAllowsMultipleSelection:YES];
    
    //        self.view = self.collectionView;
    // Add a long-press gesture recognizer
    UILongPressGestureRecognizer *lpgr =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongGesture:)];
    [self addGestureRecognizer:lpgr];
    
    self.delegate = self;
    self.dataSource = self;
    
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
    return ((point.x < self.tokenWidth)
            &&(point.y > 0));
}

#pragma mark SETTERS


-(void)setTopAlignmentOffset:(int)offSet{
    UIEdgeInsets edgeInsets = self.contentInset;
    edgeInsets.top = offSet;
    self.contentInset = edgeInsets;
    [self setNeedsDisplay];
}

-(void)setIsVisible:(BOOL)isVisible{
    _isVisible = isVisible;
    
    if (isVisible){
        CustomMKMapView *mapView = [CustomMKMapView sharedManager];
        self.frame = mapView.frame;
        
        ViewController *rootController = [ViewController sharedManager];
        [rootController.view addSubview:self];
        [self reloadData];
        
        // Move the top view to the front
        // (so the CollectionView will not block the top view after it is scrolled.)
        [rootController.view bringSubviewToFront: (UIView*) rootController.mainViewManager.activePanel];
    }else{
        [self removeFromSuperview];
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    //#warning Incomplete implementation, return the number of sections
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    [enabledEntityArray removeAllObjects];
    enabledEntityArray = [[EntityDatabase sharedManager] getEnabledEntities];
    
    if ([enabledEntityArray count] > 12){
        [TokenCollection sharedManager].isCustomGestureRecognizerEnabled = NO;
    }else{
        [TokenCollection sharedManager].isCustomGestureRecognizerEnabled = YES;
    }
    
    return [enabledEntityArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell
    int row = indexPath.row;
    
    CollectionViewCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:ArrayCellID forIndexPath:indexPath];
    
    if (row < [enabledEntityArray count]){
        [cell configureSpaceTokenFromEntity:enabledEntityArray[row]];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CELL_WIDTH, CELL_HEIGHT);
}

//----------------
// Reordering
//----------------
-(void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    SpatialEntity *anEntity = enabledEntityArray[sourceIndexPath.row];
    [enabledEntityArray removeObjectAtIndex:sourceIndexPath.row];
    [enabledEntityArray insertObject:anEntity atIndex:destinationIndexPath.row];
}

-(void)addItemFromBottom:(SpatialEntity*)anEntity{
    [enabledEntityArray insertObject:anEntity atIndex:[enabledEntityArray count]-2];
    NSUInteger index = [enabledEntityArray count]  -2;
    NSArray *indexPaths = [NSArray
                           arrayWithObject:
                           [NSIndexPath indexPathForRow:index inSection:0]];
    [self insertItemsAtIndexPaths:indexPaths];
}

#pragma mark <UICollectionViewDelegate>

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"An item is selected");
}

/*
 // Uncomment this method to specify if the specified item should be highlighted during tracking
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
 }
 */

/*
 // Uncomment this method to specify if the specified item should be selected
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
 return YES;
 }
 */

/*
 // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
 }
 
 - (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
 }
 
 - (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
 }
 */

@end
