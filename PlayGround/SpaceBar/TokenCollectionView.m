//
//  TokenCollectionView.m
//  lab_CollectionView
//
//  Created by dmiau on 12/4/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "TokenCollectionView.h"
#import "CollectionViewCell.h"
#import "EntityDatabase.h"
#import "SpatialEntity.h"
#import "TokenCollection.h"
#import "CustomMKMapView.h"
#import "SpaceBar.h"
#import "ViewController.h"
#import "ArrayEntity.h"
#import "AreaToken.h"

#import "PickerEntity.h"
#import "PickerToken.h"

//-------------------
// Parameters
//-------------------
#define CELL_WIDTH 60
#define CELL_HEIGHT 30

NSString *CellID = @"cellID";                          // UICollectionViewCell storyboard id

@implementation TokenCollectionView


+(TokenCollectionView*)sharedManager{
    static TokenCollectionView *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TokenCollectionView alloc] initSingleton];
    });
    

    return sharedInstance;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id) initSingleton{
    
    // Get the map view
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    // Configure the layout object
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake
    (30, mapView.frame.size.width- CELL_WIDTH, 0, 0);
    
    
    // Initialize a collection view
    self =
    [[TokenCollectionView alloc] initWithFrame:mapView.frame collectionViewLayout:layout];
//    [self setTopAlignmentOffset:30];
    
    [self addDragActionHandlingBlock];
    
    return self;
}

-(void)addDragActionHandlingBlock{
    // Add a dragging handling block to TokenCollection
    dragActionHandlingBlock handlingBlock = ^BOOL(UITouch *touch, SpaceToken* token){
        
        if (!self.isVisible || token.home == self)
            return NO;
        
        CGPoint tokenPoint = [touch locationInView:self];
        
        if (tokenPoint.x >  (self.frame.size.width - CELL_WIDTH * 0.5)){
            
            // The touch is in the insertion zone.
            // Now check if the entity already exists
            
            if (![self findSpaceTokenFromEntity:token.spatialEntity])
            {
                NSLog(@"Insert from dragging");
                [self insertToken:token];
                
            }else{
                // The item already exists on Collection View
                
                UIAlertController *alert = [UIAlertController
                                            alertControllerWithTitle:@"Action ignored" message:@"Token already exists" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                    
                    //do something when click button
                }];
                [alert addAction:okAction];
                [[ViewController sharedManager] presentViewController:alert animated:YES completion:nil];
            }
            return YES;
        }else{
            return NO;
        }
    };
    
    [[[TokenCollection sharedManager] handlingBlockArray] addObject: handlingBlock];
}

- (id) initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    
    // Initialize properties
    self.arrayEntity = [[ArrayEntity alloc] init];
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    self.tokenWidth = CELL_WIDTH;
    
    // Register the cell class
    //http://stackoverflow.com/questions/15184968/uicollectionview-adding-uicollectioncell
    [self registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:CellID];
    
    // Enable multiple selection
    [self setAllowsMultipleSelection:YES];
    
    // Add a long-press gesture recognizer
    UILongPressGestureRecognizer *lpgr =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongGesture:)];
    [self addGestureRecognizer:lpgr];
    
    self.delegate = self;
    self.dataSource = self;
    
    return self;
}

-(void)updateFrame:(CGRect)frame andEdgeInsets:(UIEdgeInsets)edgeInsets{
    [self setFrame:frame];
    
    //http://stackoverflow.com/questions/22475985/calling-setcollectionviewlayoutanimated-does-not-reload-uicollectionview
    [self setLayoutMargins:edgeInsets];
    
    //UIEdgeInsets UIEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right);
    [self reloadData];
}

// MARK: Gestures

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
    
    // Need to covert all points to the mapView coordinate since
    // the bound of TokenCollection view could change as the number of
    // tokens increases (this behavior is quite annoying).
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    CGPoint pointInMapView = [self convertPoint:point toView:mapView];
    
    CGRect validTokenRect = CGRectMake(mapView.frame.size.width - CELL_WIDTH, CELL_HEIGHT,
                                       CELL_WIDTH, mapView.frame.size.height);
    
    return CGRectContainsPoint(validTokenRect, pointInMapView);
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

-(void)setArrayEntity:(ArrayEntity *)arrayEntity{
    _arrayEntity = arrayEntity;
    
    if (_isVisible){
        [self.arrayEntity updateBoundingMapRect];
        [self reloadData];
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    //#warning Incomplete implementation, return the number of sections
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (![self isKindOfClass:[TokenCollectionView class]]){
        [NSException raise:@"Programming error" format:@"Method should be overloading by subclass."];
    }
    
    [self.arrayEntity setContent: [[EntityDatabase sharedManager] getEnabledEntities]];
    
    if ([[self.arrayEntity getContent] count] > 12){
        [TokenCollection sharedManager].isCustomGestureRecognizerEnabled = NO;
    }else{
        [TokenCollection sharedManager].isCustomGestureRecognizerEnabled = YES;
    }
    
    return [[self.arrayEntity getContent] count];
}

//----------------
// Producing a spacetoken
//----------------
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell
    int row = indexPath.row;
    
    CollectionViewCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:CellID forIndexPath:indexPath];
    
    //----------------------
    // I am not sure why this is necessary...
    if (cell.spaceToken){
        [cell.spaceToken removeFromSuperview];
    }
    
    // Clear all the subviews
    for (UIView *aView in [cell subviews]){
        [aView removeFromSuperview];
    }
    //----------------------
    
    // Generate a SpaceToken if there is none
    NSArray *contentArray = [self.arrayEntity getContent];
    SpatialEntity *spatialEntity = contentArray[row];
    
    if ([spatialEntity isKindOfClass:[PickerEntity class]]){
        // Generate a PickerToken (a special case)
        PickerToken *pickerToken = [[PickerToken alloc] init];
        cell.spaceToken = nil;
        [cell addSubview:pickerToken];
    }else{
        // Generate a SpaceToken
        SpaceToken* aToken = [[TokenCollection sharedManager] addTokenFromSpatialEntity:spatialEntity];
        aToken.home= self;
        aToken.index = row;
        cell.spaceToken = aToken;
        [cell addSubview:aToken];
        
        void (^cloneCreationHandler)(SpaceToken* token) = ^(SpaceToken* token){
            token.home = self;
            cell.spaceToken = token;
        };
        aToken.didCreateClone = cloneCreationHandler;
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Get the dimension of the SpaceToken
    NSArray *contentArray = [self.arrayEntity getContent];
    SpatialEntity *entity = contentArray[[indexPath row]];
    CGSize tokenSize;
    if ([entity isKindOfClass:[ArrayEntity class]]){
        tokenSize = [ArrayToken getSize];
    }else{
        tokenSize = [SpaceToken getSize];
    }
    
//    return CGSizeMake(tokenSize.width, tokenSize.height);
    return CGSizeMake(CELL_WIDTH, CELL_HEIGHT);
}

//----------------
// Reordering
//----------------
//-(BOOL)beginInteractiveMovementForItemAtIndexPath:(NSIndexPath *)indexPath{
//    return YES;
//}

-(void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSArray *contentArray = [self.arrayEntity getContent];
    SpatialEntity *anEntity = contentArray[sourceIndexPath.row];
    [self.arrayEntity removeObjectAtIndex:sourceIndexPath.row];
    [self.arrayEntity insertObject:anEntity atIndex:destinationIndexPath.row];
}

// MARK: Insert

-(void)addItemFromBottom:(SpatialEntity*)anEntity{
    
    [[EntityDatabase sharedManager] addEntity:anEntity];
    anEntity.isEnabled = YES;
    [self reloadData];
    
}


-(void) insertToken: (SpaceToken*) token{
    
    if (![self isKindOfClass:[TokenCollectionView class]]){
        [NSException raise:@"Programming error" format:@"Method should be overloading by subclass."];
    }
    
    // Need to check if an entity already exists (but disabled)
    
    
    // Create a new SpaceToken based on anchor
    // (Need to insert to entity database directly)
    [[EntityDatabase sharedManager] addEntity:token.spatialEntity];
    
    
    [self reloadData];
}

-(void)removeToken: (SpaceToken*) token{
    [token removeFromSuperview];
    
    token.spatialEntity.isEnabled = NO;
    [self reloadData];
}

#pragma mark <UICollectionViewDelegate>

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"An item is selected");
}

// MARK: Tools
-(SpaceToken*)findSpaceTokenFromEntity:(SpatialEntity*)anEntity{
    SpaceToken *outToken = nil;
    
    for (CollectionViewCell *cell in [self visibleCells]){
        if ([cell.spaceToken.spatialEntity isEqual: anEntity])
        {
            outToken = cell.spaceToken;
            break;
        }
    }
    
    return outToken;
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
