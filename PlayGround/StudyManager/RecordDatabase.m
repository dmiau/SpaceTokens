//
//  RecordDatabase.m
//  SpaceBar
//
//  Created by Daniel on 9/19/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "RecordDatabase.h"
#import "SnapshotProtocol.h"
#import "MyFileManager.h"

@implementation RecordDatabase

+(RecordDatabase*)sharedManager{
    static RecordDatabase *sharedRecordDatabase = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedRecordDatabase = [[RecordDatabase alloc] init];
        sharedRecordDatabase.recordDictionary = [[NSMutableDictionary alloc] init];
    });
    return sharedRecordDatabase;
}

-(id)init{
    self = [super init];
    if (self){
        self.recordDictionary = [[NSMutableDictionary alloc] init];
        self.name = @"unnamedRecordDB";
    }
    return self;
}

- (void)initWithSnapshotArray:(NSMutableArray*) snapshotArray{
    [self.recordDictionary removeAllObjects];
    for (Snapshot *aSnapshot in snapshotArray){
        self.recordDictionary[aSnapshot.name] = aSnapshot.record;
    }
}

#pragma mark -- Save/Load --

// iCloud related methods
-(bool)saveDatatoFileWithName: (NSString*) fullPathFileName{
    
    NSMutableString *writeString = [NSMutableString stringWithCapacity:0]; //don't worry about the capacity, it will expand as necessary
    
    for (NSString *aKey in [self.recordDictionary allKeys]) {
        
        Record *aRecord = self.recordDictionary[aKey];
        [writeString appendString:[NSString stringWithFormat:@"%@, %g\n"
                                                 , aKey, aRecord.elapsedTime]]; //the \n will put a newline in
    }
    
    [writeString writeToFile:fullPathFileName atomically:NO
                    encoding:NSUTF8StringEncoding
                       error:nil];
    return true;
}

- (bool)saveToCurrentFile{
    // Save the generated snapshot into a new file
    MyFileManager *myFileManager = [MyFileManager sharedManager];
    NSString *dirPath = [myFileManager currentFullDirectoryPath];
    NSString *fileFullPath = [dirPath stringByAppendingPathComponent:
                              [NSString stringWithFormat:@"%@.csv", self.name]];
    [self saveDatatoFileWithName:fileFullPath];
    return YES;
}


-(bool)loadFromFile:(NSString*) fullPathFileName{
    
    return true;
}
@end
