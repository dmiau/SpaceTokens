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

FOUNDATION_EXPORT NSString *const GameSetupNotification;
FOUNDATION_EXPORT NSString *const GameCleanupNotification;

typedef enum {OFF, STUDY, DEMO, AUTHORING} GameManagerStatus;
typedef enum {CHECKING, PROGRESS, SCLAE, JUMP, ZOOMTOFIT} TaskType;

//-----------------
// GameManager interface
//-----------------
@interface GameManager : NSObject{
    SnapshotDatabase *snapshotDatabase;
}

@property GameManagerStatus gameManagerStatus;
@property int gameCounter;
@property Snapshot *activeSnapshot;

// Initialization
+ (id)sharedManager; // Singleton method

// Game execution
- (void)runSnapshotIndex:(int)index;
- (void)reportCompletionFromSnashot:(id<SnapshotProtocol>) snapshot;
@end
