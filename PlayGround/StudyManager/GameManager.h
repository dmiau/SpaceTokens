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


@interface GameManager : NSObject
@property GameManagerStatus gameManagerStatus;
@property int gameCounter;
@property SnapshotDatabase *snapshotDatabase;
@property NSArray *gameVector;

- (id)initWithSnapshotDatabase: (SnapshotDatabase*) snapshotDatabase
                    GameVector:(NSArray*) gameVector;
- (void)runSnapshotIndex:(int)index;

- (void)reportCompletionFromSnashot:(id<SnapshotProtocol>) snapshot;
@end
