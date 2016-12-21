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




- (void)debugInit{
    
    MyFileManager *myFileManager = [MyFileManager sharedManager];
    
    NSString *dirPath = [myFileManager currentFullDirectoryPath];
    NSString *fileFullPath = [dirPath stringByAppendingPathComponent:@"mySnapshotDB.snapshot"];
    
    [self loadFromFile:fileFullPath];
}

@end
