//
//  SnapshotProtocol.h
//  SpaceBar
//
//  Created by Daniel on 8/6/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#ifndef SnapshotProtocol_h
#define SnapshotProtocol_h
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "POI.h"
#import "Record.h"

@class ViewController;

//----------------------
// Protocol for snapshot
//----------------------
@protocol SnapshotProtocol <NSObject>

@required
- (void)setup;
- (void)cleanup;

@end

//----------------------
// Snapshot interface
//----------------------
@interface Snapshot : POI

@property NSString *instructions;
@property NSMutableArray <POI*> *highlightedPOIs;
@property ViewController *rootViewController;
@property NSMutableArray <POI*> *targetedPOIs;
@property Record *record;

@end

#endif /* SnapshotProtocol_h */
