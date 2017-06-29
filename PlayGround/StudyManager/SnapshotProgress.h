//
//  SnapshotProgress.h
//  NavTools
//
//  Created by dmiau on 8/7/16.
//  Copyright © 2016 dmiau. All rights reserved.
//
#import "SnapshotProtocol.h"
#import "POI.h"

@class ViewController;

@interface SnapshotProgress : Snapshot <SnapshotProtocol>

@property NSString *routeID;

@end
