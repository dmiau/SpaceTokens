//
//  GameManager.h
//  SpaceBar
//
//  Created by dmiau on 8/5/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SnapshotProtocol.h"

FOUNDATION_EXPORT NSString *const GameSetupNotification;
FOUNDATION_EXPORT NSString *const GameCleanupNotification;

typedef enum {OFF, STUDY, DEMO, AUTHORING} GameManagerStatus;
typedef enum {CHECKING, PROGRESS, SCLAE, JUMP, ZOOMTOFIT} TaskType;

// Game flow statistics to display for the player
typedef struct {
    int indexInCategory;
    int countInCategory;
} TaskInformationStruct;

@class SnapshotDatabase;
@class RecordDatabase;

//-----------------
// GameManager interface
//-----------------
@interface GameManager : NSObject
@property GameManagerStatus gameManagerStatus;
@property int gameCounter;

@property SnapshotDatabase *snapshotDatabase;
@property RecordDatabase *recordDatabase;

@property Snapshot *activeSnapshot;
@property TaskInformationStruct activeTaskInformationStruct;

// Initialization
+ (GameManager*)sharedManager; // Singleton method

// Game execution
- (void)runSnapshotIndex:(int)index;
- (void)reportCompletionFromSnashot:(id<SnapshotProtocol>) snapshot;
@end
