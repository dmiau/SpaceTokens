//
//  SnapshotDatabase+Debug.m
//  SpaceBar
//
//  Created by Daniel on 9/4/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SnapshotDatabase+Debug.h"
#import "SnapshotChecking.h"

@implementation SnapshotDatabase (Debug)


- (void)debugInit{
    // Initialize a bunch of snapshots temporary
    NSArray *keys = @[@"PC1", @"PC2", @"TC1", @"TC2"];
    for (NSString *aKey in keys){
        SnapshotChecking *checking = [[SnapshotChecking alloc] init];
        self.snapshotDictrionary[aKey] = checking;
    }
}

@end
