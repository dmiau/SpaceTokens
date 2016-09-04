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

@interface SnapshotAnchorPlus : POI <SnapshotProtocol>

@property ViewController *rootViewController;
@property NSMutableArray <POI*> *targetedPOIs;

@end
