//
//  TaskGenerator.h
//  SpaceBar
//
//  Created by dmiau on 9/26/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SnapshotPlace;
@class SnapshotAnchorPlus;
@class POI;

@interface TaskGenerator : NSObject{
    NSMutableDictionary <NSString*, NSArray*> *taskByCategory;
}

@property NSArray<NSArray*> *gameVectorCollection;
// example output:
// control:anchor:normal,
// control:place:normal,
// spacetoken:anchor:mutant,
// spacetoken:place:mutant

@property NSDictionary *gameSnapshotDictionary;
// example output:
//"ANCHOR:mutant:0" = "latlon: 51.5044, -0.0772236";
//"ANCHOR:mutant:1" = "latlon: 51.5044, -0.0772236";
//"ANCHOR:mutant:2" = "latlon: 51.5044, -0.0772236";
//"ANCHOR:mutant:3" = "latlon: 51.5044, -0.0772236";
//"ANCHOR:mutant:4" = "latlon: 51.5044, -0.0772236";
//"ANCHOR:mutant:5" = "latlon: 51.5044, -0.0772236";
//"ANCHOR:mutant:6" = "latlon: 51.5044, -0.0772236";
//"ANCHOR:mutant:7" = "latlon: 51.5044, -0.0772236";
//"ANCHOR:mutant:8" = "latlon: 51.5044, -0.0772236";
//"ANCHOR:mutant:9" = "latlon: 51.5044, -0.0772236";
//"ANCHOR:normal:0" = "latlon: 51.5044, -0.0772236";
//"ANCHOR:normal:1" = "latlon: 51.5044, -0.0772236";
//"ANCHOR:normal:2" = "latlon: 51.5044, -0.0772236";
//"ANCHOR:normal:3" = "latlon: 51.5044, -0.0772236";
//"ANCHOR:normal:4" = "latlon: 51.5044, -0.0772236";
//"ANCHOR:normal:5" = "latlon: 51.5044, -0.0772236";
//"ANCHOR:normal:6" = "latlon: 51.5044, -0.0772236";
//"ANCHOR:normal:7" = "latlon: 51.5044, -0.0772236";
//"ANCHOR:normal:8" = "latlon: 51.5044, -0.0772236";
//"ANCHOR:normal:9" = "latlon: 51.5044, -0.0772236";
//"PLACE:mutant:east" = "latlon: 40.7534, -73.9415";
//"PLACE:mutant:north" = "latlon: 40.7534, -73.9415";
//"PLACE:mutant:northeast" = "latlon: 40.7534, -73.9415";
//"PLACE:mutant:northwest" = "latlon: 40.7534, -73.9415";
//"PLACE:mutant:south" = "latlon: 40.7534, -73.9415";
//"PLACE:mutant:southeast" = "latlon: 40.7534, -73.9415";
//"PLACE:mutant:southwest" = "latlon: 40.7534, -73.9415";
//"PLACE:mutant:west" = "latlon: 40.7534, -73.9415";
//"PLACE:normal:east" = "latlon: 40.7534, -73.9415";
//"PLACE:normal:north" = "latlon: 40.7534, -73.9415";
//"PLACE:normal:northeast" = "latlon: 40.7534, -73.9415";
//"PLACE:normal:northwest" = "latlon: 40.7534, -73.9415";
//"PLACE:normal:south" = "latlon: 40.7534, -73.9415";
//"PLACE:normal:southeast" = "latlon: 40.7534, -73.9415";
//"PLACE:normal:southwest" = "latlon: 40.7534, -73.9415";
//"PLACE:normal:west" = "latlon: 40.7534, -73.9415";


+(TaskGenerator*)sharedManager;

// Generated files will be save to the file system
- (void)generateTaskFiles:(int)fileCount;

@end
