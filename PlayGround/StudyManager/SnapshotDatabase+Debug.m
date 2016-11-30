//
//  SnapshotDatabase+Debug.m
//  SpaceBar
//
//  Created by Daniel on 9/4/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SnapshotDatabase+Debug.h"
#import "SnapshotChecking.h"
#import "SnapshotAnchorPlus.h"
#import "SnapshotPlace.h"
#import "MyFileManager.h"
#import "TaskGenerator.h"

@implementation SnapshotDatabase (Debug)


- (void)generateNewTasks{
    TaskGenerator *taskGenerator = [TaskGenerator sharedManager];
    
    // Generate tasks
    NSMutableArray <Snapshot*> *cachedSnapshotArray = [self.snapshotArray mutableCopy];
    
    self.snapshotArray = [taskGenerator generateTasks];
    
    // Save the generated snapshot into a new file
    MyFileManager *myFileManager = [MyFileManager sharedManager];
    NSString *dirPath = [myFileManager currentFullDirectoryPath];
    NSString *fileFullPath = [dirPath stringByAppendingPathComponent:@"study0.snapshot"];
    [self saveDatatoFileWithName:fileFullPath];
    
    // Restore the original snapshotArray
    self.snapshotArray = cachedSnapshotArray;
}


- (void)debugInit{
    
    MyFileManager *myFileManager = [MyFileManager sharedManager];
    
    NSString *dirPath = [myFileManager currentFullDirectoryPath];
    NSString *fileFullPath = [dirPath stringByAppendingPathComponent:@"mySnapshotDB.snapshot"];
    
    [self loadFromFile:fileFullPath];
}

@end
