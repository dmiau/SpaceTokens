//
//  SnapshotDatabase.h
//  SpaceBar
//
//  Created by Daniel on 8/6/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SnapshotDatabase : NSObject

@property NSString *name;
@property NSMutableDictionary *snapshotDictrionary;

- (id)initWithDatabaseName:(NSString*) databaseName;

// iCloud related methods
-(bool)saveDatatoFileWithName: (NSString*) fullPathFileName;
-(bool)loadFromFile:(NSString*) fullPathFileName;

@end
