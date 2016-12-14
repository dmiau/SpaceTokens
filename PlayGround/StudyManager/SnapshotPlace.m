//
//  SnapshotPlace.m
//  SpaceBar
//
//  Created by Daniel on 9/8/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SnapshotPlace.h"
#import "ViewController.h"
#import "../Map/CustomMKMapView.h"
#import "Constants.h"
#import "Record.h"
#import "GameManager.h"
#import "PlaceInstructionView.h"
#import "TokenCollection.h"

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
    // Present the instruction panel
    //----------------
    PlaceInstructionView *instructionView = [[[NSBundle mainBundle] loadNibNamed:@"PlaceInstructionView" owner:self options:nil] firstObject];
    
    [instructionView prepareInstruction:self];
    [instructionView showInstruction];
}

@end
