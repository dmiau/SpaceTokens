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

// condition enum
typedef enum {CONTROL, EXPERIMENT} Condition;

//----------------------
// Protocol for snapshot
//----------------------
@protocol SnapshotProtocol <NSObject>

- (void)cleanup;

@required
- (void)setup;


@end

//----------------------
// Snapshot interface
//----------------------
@interface Snapshot : POI <SnapshotProtocol>{
    MKCircle *targetCircle;
    MKCircle *completionIndicator;
    NSTimer *validatorTimer;
}
@property ViewController *rootViewController;

@property NSString *instructions;
@property NSMutableArray <POI*> *highlightedPOIs;
@property NSMutableArray <POI*> *poisForSpaceTokens; // pois to generate SpaceToken
@property NSMutableArray <POI*> *targetedPOIs;

// For those tasks that require multiple selections
@property NSArray *segmentOptions;
@property NSSet *correctAnswers;

@property Record *record;
@property Condition condition;

// Methods to setup and validate the tasks
- (void)setupMapSpacebar;
- (void)drawOnePointVisualTarget;
- (void)drawTwoPointsVisualTarget;
- (void)onePointValidator;
- (void)twoPointsValidator;

- (void)segmentControlValidator;
@end

#endif /* SnapshotProtocol_h */
