//
//  SnapshotAnchorPlus.h
//  SpaceBar
//
//  Created by Daniel on 9/4/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SnapshotProtocol.h"
#import "POI.h"

@class ViewController;
@class Record;

@interface SnapshotAnchorPlus : POI <SnapshotProtocol>

@property NSMutableArray <POI*> *highlightedPOIs;
@property ViewController *rootViewController;
@property NSMutableArray <POI*> *targetedPOIs;
@property Record *record;

@end
