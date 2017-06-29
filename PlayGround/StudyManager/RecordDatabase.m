//
//  RecordDatabase.m
//  NavTools
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
    int i = 0;
    for (Snapshot *aSnapshot in snapshotArray){
        
        //---------------
        // Fill in details of the record
        //---------------
        aSnapshot.record.order = i++;
        aSnapshot.record.name = aSnapshot.name;
        self.recordDictionary[aSnapshot.name] = aSnapshot.record;
    }
}

#pragma mark -- Save/Load --

// iCloud related methods
-(bool)saveDatatoFileWithName: (NSString*) fullPathFileName{
    
    NSMutableArray *lineArray = [[NSMutableArray alloc] init];
    //---------------------
    // Generate one line per task
    //---------------------
    
    // header
    NSString *header = @"id, order, isAnswered, isCorrect, elapsedTime, startTime, endTime";
    [lineArray addObject:header];
    
    for (NSString *aKey in [self.recordDictionary allKeys]) {
        Record *aRecord = self.recordDictionary[aKey];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat: @"HH:mm:ss"];
        NSString *startDateString = [dateFormat stringFromDate:aRecord.startDate];
        NSString *endDateString = [dateFormat stringFromDate:aRecord.endDate];
        
        NSString *taskLine = [NSString stringWithFormat:
                              @"%@, %d, %d, %d, %f, %@, %@",
                aRecord.name, aRecord.order, aRecord.isAnswered, aRecord.isCorrect,  aRecord.elapsedTime, startDateString, endDateString];
        [lineArray addObject:taskLine];
    }
    
    NSString *writeString = [lineArray componentsJoinedByString:@"\n"];
    
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
