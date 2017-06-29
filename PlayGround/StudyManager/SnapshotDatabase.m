//
//  SnapshotDatabase.m
//  NavTools
//
//  Created by Daniel on 8/6/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SnapshotDatabase.h"
#import "SnapshotProtocol.h"
#import <UIKit/UIkit.h>
#import "MyFileManager.h"

//--------------------
// Global contants
static NSString *const TEMPLATE_DB_NAME = @"gameTemplate.snapshot";
//--------------------

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
    _snapshotArray = [[NSMutableArray alloc] init];
    return self;
}

#pragma mark --Save and Load --

// saving and loading the object
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.snapshotArray forKey:@"snapshotArray"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [self init];
    self.name = [coder decodeObjectForKey:@"name"];
    self.snapshotArray = [[coder decodeObjectForKey:@"snapshotArray"] mutableCopy];
    return self;
}

// Deep copy
-(id) copyWithZone:(NSZone *) zone
{
    SnapshotDatabase *object = [[[self class] alloc] init];
    object.name = self.name;
    object.snapshotArray = self.snapshotArray;

    return object;
}

#pragma mark -- convenient method to load a specific snapshot --
- (void)loadGameTemplateDatabase{    
    MyFileManager *myFileManager = [MyFileManager sharedManager];
    NSString *dirPath = [myFileManager currentFullDirectoryPath];
    NSString *fileFullPath = [dirPath stringByAppendingPathComponent:TEMPLATE_DB_NAME];
    if (![self loadFromFile:fileFullPath]){
        self.snapshotArray = [[NSMutableArray alloc] init];
    }
    self.currentFileName = TEMPLATE_DB_NAME;
}

- (bool)saveToCurrentFile{
    // Save the generated snapshot into a new file
    MyFileManager *myFileManager = [MyFileManager sharedManager];
    NSString *dirPath = [myFileManager currentFullDirectoryPath];
    NSString *fileFullPath = [dirPath stringByAppendingPathComponent:self.currentFileName];
    [self saveDatatoFileWithName:fileFullPath];
    return YES;
}

- (void)loadGameDatabaseWithID:(int)ID{
    
}

#pragma mark -- save and load --
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
        self.snapshotArray = snapshotDB.snapshotArray;
        
        // Store the current file name
        self.currentFileName = [fullPathFileName lastPathComponent];
        
        return YES;
    }else{
        NSLog(@"%@ does not exist.", fullPathFileName);
        return NO;
    }

}
@end
