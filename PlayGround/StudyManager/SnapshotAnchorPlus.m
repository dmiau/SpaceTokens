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

    [[CustomMKMapView sharedManager] camera].heading = 0;
    
    
    //------------------------
    // Set up the environment according to the condition
    //------------------------
    if (self.condition == CONTROL){
        [[SpaceBar sharedManager] setIsAnchorAllowed: NO];
        [SpaceBar sharedManager].isMultipleTokenSelectionEnabled = NO;
    }else{
        [[SpaceBar sharedManager] setIsAnchorAllowed: YES];
        [SpaceBar sharedManager].isMultipleTokenSelectionEnabled = YES;
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
