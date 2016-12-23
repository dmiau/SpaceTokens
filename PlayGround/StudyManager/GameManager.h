//
//  GameManager.h
//  SpaceBar
//
//  Created by dmiau on 8/5/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SnapshotProtocol.h"
#import "SnapshotDatabase.h"
#import "RecordDatabase.h"

FOUNDATION_EXPORT NSString *const GameSetupNotification;
FOUNDATION_EXPORT NSString *const GameCleanupNotification;

typedef enum {OFF, STUDY, DEMO, AUTHORING} GameManagerStatus;
typedef enum {CHECKING, PROGRESS, SCLAE, JUMP, ZOOMTOFIT} TaskType;

//-----------------
// GameManager interface
//-----------------
@interface GameManager : NSObject{
    SnapshotDatabase *snapshotDatabase;
    RecordDatabase *recordDatabase;
}

@property GameManagerStatus gameManagerStatus;
@property int gameCounter;
@property Snapshot *activeSnapshot;

// Initialization
+ (GameManager*)sharedManager; // Singleton method

// Game execution
- (void)runSnapshotIndex:(int)index;
- (void)reportCompletionFromSnashot:(id<SnapshotProtocol>) snapshot;
@end
