//
//  SnapshotAnchorPlus.m
//  SpaceBar
//
//  Created by Daniel on 9/4/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SnapshotAnchorPlus.h"

#import "ViewController.h"
#import "CustomMKMapView.h"
#import "Constants.h"
#import "Record.h"
#import "GameManager.h"
#import "SpaceBar.h"
#import "AnchorInstructionView.h"
#import "TokenCollection.h"

@implementation SnapshotAnchorPlus


- (void)setup{    
    [self setupMapSpacebar];

    
    
//    //Draw the target
//    [self drawTwoPointsVisualTarget];
//    
//    // Start the validator
//    // listen to the map change event
//    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
//    [center addObserver:self
//               selector:@selector(twoPointsValidator)
//                   name:MapUpdatedNotification
//                 object:nil];
    
    [[CustomMKMapView sharedManager] camera].heading = 0;
    
    
    //------------------------
    // Task specific set up
    //------------------------
    if (self.condition == CONTROL){
        [[SpaceBar sharedManager] setIsAnchorAllowed: NO];
    }else{
        [[SpaceBar sharedManager] setIsAnchorAllowed: YES];
    }
    
    
    // Turn on the labels
    for (POI *aPOI in self.poisForSpaceTokens){
        aPOI.annotation.isLableOn = YES;
    }    
    
    for (POI *aPOI in self.highlightedPOIs){
        aPOI.annotation.isLableOn = YES;
    }
    
    //----------------
    // Present the instruction panel
    //----------------
    AnchorInstructionView *instructionView = [[[NSBundle mainBundle] loadNibNamed:@"AnchorInstructionView" owner:self options:nil] firstObject];
    
    [instructionView prepareInstruction:self];
    [instructionView showInstruction];
}

-(void)cleanup{
    
    [super cleanup];
}


@end
