//
//  SnapshotDatabase+Debug.m
//  SpaceBar
//
//  Created by Daniel on 9/4/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SnapshotDatabase+Debug.h"
#import "SnapshotChecking.h"
#import "SnapshotAnchorPlus.h"

@implementation SnapshotDatabase (Debug)


- (void)debugInit{
    // Initialize a bunch of snapshots temporary
    
    
    SnapshotAnchorPlus *ap1 = [[SnapshotAnchorPlus alloc] init];
    ap1.latLon = CLLocationCoordinate2DMake(40.715, -74.0099);
    ap1.coordSpan = MKCoordinateSpanMake(0.0104498, 0.01);
    ap1.instructions = @"Examine the area between W.T.C. and Bronx.";
    
    POI *wtc = [[POI alloc] init];
    wtc.latLon = CLLocationCoordinate2DMake(40.711801, -74.013120);
    wtc.name = @"W.T.C.";
    
    [ap1.highlightedPOIs addObject:wtc];
    
    POI *home = [[POI alloc] init];
    home.latLon = CLLocationCoordinate2DMake(40.885722, -73.912491);
    home.name = @"home";
    
    [ap1.targetedPOIs addObject:wtc];
    [ap1.targetedPOIs addObject:home];
    
    self.snapshotDictrionary[@"AP1"] = ap1;
    
    NSArray *keys = @[@"PC1", @"PC2", @"TC1", @"TC2"];
    for (NSString *aKey in keys){
        SnapshotChecking *checking = [[SnapshotChecking alloc] init];
        self.snapshotDictrionary[aKey] = checking;
    }
}

@end
