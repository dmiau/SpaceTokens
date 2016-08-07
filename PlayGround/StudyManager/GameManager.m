//
//  GameManager.m
//  SpaceBar
//
//  Created by dmiau on 8/5/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "GameManager.h"

@implementation GameManager

- (id)initWithSnapshotDatabase: (SnapshotDatabase*) snapshotDatabase
                    GameVector:(NSArray*) gameVector
{
    self = [super init];
    if (self){
        self.gameManagerStatus = OFF;
        self.gameCounter = 0;
        self.gameVector = gameVector;
        self.snapshotDatabase = snapshotDatabase;
    }
    return self;
}

// Execute a specific snapshot
- (void)runSnapshotIndex:(int)index{
    self.gameCounter = index;
    NSString *code = self.gameVector[index];
    id<SnapshotProtocol> aSnapshot = self.snapshotDatabase.snapshotDictrionary[code];
    [aSnapshot setup];
}

- (void)reportCompletionFromSnashot:(id<SnapshotProtocol>) snapshot{
    
}
@end
