//
//  SnapshotDatabase.h
//  SpaceBar
//
//  Created by Daniel on 8/6/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Snapshot;

@interface SnapshotDatabase : NSObject

@property NSString *name;
@property NSString *currentFileName;
@property NSMutableArray <Snapshot*> *snapshotArray;

+(id)sharedManager;
- (NSMutableArray*)generateSnapshotArrayFromGameVector:(NSArray*) gameVector;

- (NSArray*)allSnapshotIDs;

// iCloud related methods
-(bool)saveToCurrentFile;
-(bool)saveDatatoFileWithName: (NSString*) fullPathFileName;
-(bool)loadFromFile:(NSString*) fullPathFileName;

// Debug methods
- (void)debugInit;
- (void)generateNewTasks;

// Convenient method to load a specific snapshot database
- (void)loadGameTemplateDatabase;
- (void)loadGameDatabaseWithID:(int)ID;

@end
