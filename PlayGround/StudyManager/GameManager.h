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

typedef enum {OFF, STUDY, DEMO, AUTHORING} GameManagerStatus;
typedef enum {CHECKING, PROGRESS, SCLAE, JUMP, ZOOMTOFIT} TaskType;

@interface GameManager : NSObject
@property GameManagerStatus gameManagerStatus;
@property int gameCounter;
@property SnapshotDatabase *snapshotDatabase;
@property NSArray *gameVector;

// Initialization
+ (id)sharedManager; // Singleton method

// Game execution
- (void)runSnapshotIndex:(int)index;


- (id)initWithSnapshotDatabase: (SnapshotDatabase*) snapshotDatabase
                    GameVector:(NSArray*) gameVector;
- (void)reportCompletionFromSnashot:(id<SnapshotProtocol>) snapshot;
@end
