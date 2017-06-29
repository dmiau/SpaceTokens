//
//  SnapshotProtocol.h
//  NavTools
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

// Two instructions will be generated, and only the approricate one (either control or spaceToken, will be used in the study)
@property NSString *controlInstructions;
@property NSString *spaceTokenInstructions;
@property NSString *instructions;

@property NSMutableArray <POI*> *highlightedPOIs;
// stores the POI need to be highlighted on the map
// (note that annocations will be added automatically for POIs associated with SpaceTokens)
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

- (NSString*)firstNComponentsFromCode:(int)n;
@end

#endif /* SnapshotProtocol_h */
