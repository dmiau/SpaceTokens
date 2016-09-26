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
#import "SnapshotPlace.h"
#import "MyFileManager.h"
#import "TaskGenerator.h"

@implementation SnapshotDatabase (Debug)


- (void)generateNewTasks{
    TaskGenerator *taskGenerator = [TaskGenerator sharedManager];
    
    // Generate tasks
    self.snapshotArray = [taskGenerator generateTasks];
}


- (void)debugInit{
    
    MyFileManager *myFileManager = [MyFileManager sharedManager];
    
    NSString *dirPath = [myFileManager currentFullDirectoryPath];
    NSString *fileFullPath = [dirPath stringByAppendingPathComponent:@"mySnapshotDB.snapshot"];
    
    [self loadFromFile:fileFullPath];
    
//    // Initialize a bunch of snapshots temporary
//    
//    //---------------------
//    // Add an anchor+x task
//    //---------------------
//    SnapshotAnchorPlus *ap1 = [[SnapshotAnchorPlus alloc] init];
//    ap1.name = @"Anchor:1";
//    ap1.latLon = CLLocationCoordinate2DMake(40.715, -74.0099);
//    ap1.coordSpan = MKCoordinateSpanMake(0.0104498, 0.01);
//    ap1.instructions = @"Examine the area between W.T.C. and Bronx.";
//    
//    POI *wtc = [[POI alloc] init];
//    wtc.latLon = CLLocationCoordinate2DMake(40.711801, -74.013120);
//    wtc.name = @"W.T.C.";
//    
//    [ap1.highlightedPOIs addObject:wtc];
//    
//    POI *home = [[POI alloc] init];
//    home.latLon = CLLocationCoordinate2DMake(40.885722, -73.912491);
//    home.name = @"home";
//    
//    [ap1.targetedPOIs addObject:wtc];
//    [ap1.targetedPOIs addObject:home];
//    
//    [self.snapshotArray addObject: ap1];
//    
//    //---------------------
//    // Add a PLACE task
//    //---------------------
//    SnapshotPlace *pl1 = [[SnapshotPlace alloc] init];
//    pl1.name = @"Place:1";
//    pl1.latLon = CLLocationCoordinate2DMake(40.7527, -73.9772);
//    pl1.coordSpan = MKCoordinateSpanMake(0.0104439, 0.01);
//    pl1.instructions = @"Examine the area west of Grand Central.";
//    
//    POI *west = [[POI alloc] init];
//    west.name = @"West";
//    west.latLon = CLLocationCoordinate2DMake(40.7529, -73.9998);
//    west.coordSpan = MKCoordinateSpanMake(0.00420188, 0.00402331);
//    [pl1.targetedPOIs addObject:west];
//    
//    [self.snapshotArray addObject: pl1];
}

@end
