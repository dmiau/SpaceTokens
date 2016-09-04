//
//  SnapshotDatabase.m
//  SpaceBar
//
//  Created by Daniel on 8/6/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SnapshotDatabase.h"

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

// iCloud related methods
-(bool)saveDatatoFileWithName: (NSString*) fullPathFileName{
    return YES;
}

-(bool)loadFromFile:(NSString*) fullPathFileName{
    return YES;
}
@end
