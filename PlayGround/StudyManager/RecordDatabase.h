//
//  RecordDatabase.h
//  SpaceBar
//
//  Created by Daniel on 9/19/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Record.h"

@interface RecordDatabase : NSObject

@property NSString *name;
@property NSMutableDictionary <NSString*, Record*> *recordDictionary;

+(RecordDatabase*)sharedManager;
- (void)initWithSnapshotArray:(NSMutableArray*) snapshotArray;

// iCloud related methods
-(bool)saveDatatoFileWithName: (NSString*) fullPathFileName;
- (bool)saveToCurrentFile;
-(bool)loadFromFile:(NSString*) fullPathFileName;

@end
