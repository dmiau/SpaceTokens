//
//  SnapshotAnchorPlus.m
//  NavTools
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
#import "NavTools.h"
#import "AnchorInstructionView.h"
#import "TokenCollection.h"

@implementation SnapshotAnchorPlus


- (void)setup{    
    [self setupMapSpacebar];
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    GMSCameraPosition *myCamera = mapView.camera;
    GMSCameraPosition *myNewCamera = [GMSCameraPosition
                                      cameraWithLatitude:myCamera.target.latitude
                                      longitude:myCamera.target.longitude
                                      zoom:myCamera.zoom
                                      bearing:0
                                      viewingAngle:myCamera.viewingAngle];
    mapView.camera = myNewCamera;
    
    //------------------------
    // Set up the environment according to the condition
    //------------------------
    if (self.condition == CONTROL){
        [[NavTools sharedManager] setIsAnchorAllowed: NO];
        [NavTools sharedManager].isMultipleTokenSelectionEnabled = NO;
    }else{
        [[NavTools sharedManager] setIsAnchorAllowed: YES];
        [NavTools sharedManager].isMultipleTokenSelectionEnabled = YES;
    }
    
    // Turn on the labels
    for (POI *aPOI in self.poisForSpaceTokens){
        aPOI.annotation.isLabelOn = YES;
    }    
    
    for (POI *aPOI in self.highlightedPOIs){
        aPOI.annotation.isLabelOn = YES;
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
