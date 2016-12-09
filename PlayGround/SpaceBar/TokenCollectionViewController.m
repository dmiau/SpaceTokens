//
//  TokenCollectionViewController.m
//  lab_CollectionView
//
//  Created by dmiau on 12/5/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "TokenCollectionViewController.h"
#import "CustomCollectionView.h"
#import "CollectionViewCell.h"
#import "EntityDatabase.h"
#import "SpatialEntity.h"

#define CELL_WIDTH 60
#define CELL_HEIGHT 20

@interface TokenCollectionViewController ()

@end

@implementation TokenCollectionViewController{
    NSMutableArray *enabledEntityArray;
}

//static NSString * const reuseIdentifier = @"Cell";
static NSString * const CellID = @"cellID";   // UICollectionViewCell storyboard id

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout{
    self = [super initWithCollectionViewLayout:layout];
    
    if (self){
        
        // Initialize instance variable
        enabledEntityArray = [[NSMutableArray alloc] init];
        
        //--------------------------
        // Initialize a collection view
        //--------------------------
//        CustomCollectionView *customCollectionView
//        = [[CustomCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
//        customCollectionView.tokenWidth = CELL_WIDTH;        
//        self.collectionView = customCollectionView;
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];                
        
        // Register a custom cell
        [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:CellID];
        
        [self.collectionView setBackgroundColor:[UIColor clearColor]];

        // Enable multiple selection
        [self.collectionView setAllowsMultipleSelection:YES];
        
        self.view = self.collectionView;

        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;

    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;

    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    [enabledEntityArray removeAllObjects];
    
    // Collect a list of enabled entities
    for (SpatialEntity *anEntity in [[EntityDatabase sharedManager] entityArray])
    {
        if (anEntity.isEnabled){
            [enabledEntityArray addObject:anEntity];
        }
    }
    
//    return [enabledEntityArray count];
    return 30;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    int row = indexPath.row;
    
    // Configure the cell
    
    CollectionViewCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:CellID forIndexPath:indexPath];
        
    if (row < ([enabledEntityArray count]-1)){
        [cell configureSpaceTokenFromEntity:enabledEntityArray[row]];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CELL_WIDTH, CELL_HEIGHT);
}

-(void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    // move your data order
    NSLog(@"Item moved.");
}


#pragma mark <UICollectionViewDelegate>

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
