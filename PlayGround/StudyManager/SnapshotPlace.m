//
//  SnapshotPlace.m
//  SpaceBar
//
//  Created by Daniel on 9/8/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SnapshotPlace.h"
#import "ViewController.h"
#import "CustomMKMapView.h"
#import "Constants.h"
#import "Record.h"
#import "GameManager.h"
#import "PlaceInstructionView.h"
#import "TokenCollection.h"
#import "TokenCollectionView.h"

@implementation SnapshotPlace


- (void)setup{
    

    [self setupMapSpacebar];
    // Set up the environment based on the condition
    if (self.condition == CONTROL){
        [TokenCollection sharedManager].isTokenDraggingEnabled = NO;
    }else{
        [TokenCollection sharedManager].isTokenDraggingEnabled = YES;
    }
    
    //Draw the target
    [self drawOnePointVisualTarget];
    
    // Start the validator
    // listen to the map change event
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(onePointValidator)
                   name:MapUpdatedNotification
                 object:nil];
 
    //----------------
    // Modify CollectionView inset
    //----------------
    TokenCollectionView *tokenCollectionView = [TokenCollectionView sharedManager];
    [tokenCollectionView setTopAlignmentOffset:tokenCollectionView.frame.size.height/2-30];
    
    //----------------
    // Present the instruction panel
    //----------------
    PlaceInstructionView *instructionView = [[[NSBundle mainBundle] loadNibNamed:@"PlaceInstructionView" owner:self options:nil] firstObject];
    
    [instructionView prepareInstruction:self];
    [instructionView showInstruction];
}

- (void)cleanup{
    //----------------
    // Modify CollectionView inset
    //----------------
    TokenCollectionView *tokenCollectionView = [TokenCollectionView sharedManager];
    [tokenCollectionView setTopAlignmentOffset:30];
    [super cleanup];
}

@end
