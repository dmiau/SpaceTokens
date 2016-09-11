//
//  SnapshotDatabase.m
//  SpaceBar
//
//  Created by Daniel on 8/6/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SnapshotDatabase.h"

@implementation SnapshotDatabase

+(id)sharedManager{
    static SnapshotDatabase* sharedSnapshotDatabase = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSnapshotDatabase = [[SnapshotDatabase alloc] init];
    });
    return sharedSnapshotDatabase;
}

- (id)init{
    self.snapshotDictrionary = [[NSMutableDictionary alloc] init];
    [self debugInit];
    return self;
}

#pragma mark --Save and Load --

// saving and loading the object
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.snapshotDictrionary forKey:@"snapshotDictrionary"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [self init];
    self.name = [coder decodeObjectForKey:@"name"];
    self.snapshotDictrionary = [[coder decodeObjectForKey:@"snapshotDictrionary"] mutableCopy];
    return self;
}

// Deep copy
-(id) copyWithZone:(NSZone *) zone
{
    SnapshotDatabase *object = [[SnapshotDatabase alloc] init];
    object.name = self.name;
    object.snapshotDictrionary = self.snapshotDictrionary;

    return object;
}

// iCloud related methods
-(bool)saveDatatoFileWithName: (NSString*) fullPathFileName{
    // Save the entire database to a file
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject: self];
    
    if ([data writeToFile:fullPathFileName atomically:YES]){
        NSLog(@"%@ saved successfully!", fullPathFileName);
        return YES;
    }else{
        NSLog(@"Failed to save %@", fullPathFileName);
        return NO;
    }
}

-(bool)loadFromFile:(NSString*) fullPathFileName{
    // Read content from a file
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:fullPathFileName]){
        
        NSData *data = [NSData dataWithContentsOfFile:fullPathFileName];
        SnapshotDatabase *snapshotDB = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        self.name = snapshotDB.name;
        self.snapshotDictrionary = snapshotDB.snapshotDictrionary;
        return YES;
    }else{
        NSLog(@"%@ does not exist.", fullPathFileName);
        return NO;
    }
}
@end
