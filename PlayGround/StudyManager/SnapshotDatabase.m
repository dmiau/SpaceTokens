//
//  SnapshotDatabase.m
//  SpaceBar
//
//  Created by Daniel on 8/6/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SnapshotDatabase.h"
#import "SnapshotChecking.h"

@implementation SnapshotDatabase

- (id)initWithDatabaseName:(NSString*) databaseName{
    self = [super init];
    if (self){
        self.name = databaseName;
        self.snapshotDictrionary = [[NSMutableDictionary alloc] init];
        
        [self debugInit];
    }
    return self;
}

- (void)debugInit{
    // Initialize a bunch of snapshots temporary
    NSArray *keys = @[@"PC1", @"PC2", @"TC1", @"TC2"];
    for (NSString *aKey in keys){
        SnapshotChecking *checking = [[SnapshotChecking alloc] init];
        self.snapshotDictrionary[aKey] = checking;
    }
}


// iCloud related methods
-(bool)saveDatatoFileWithName: (NSString*) fullPathFileName{
    return YES;
}

-(bool)loadFromFile:(NSString*) fullPathFileName{
    return YES;
}
@end
