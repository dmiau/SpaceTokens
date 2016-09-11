//
//  MyFileManager.m
//  SpaceBar
//
//  Created by dmiau on 8/3/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "MyFileManager.h"

@implementation MyFileManager

- (id) init{
    if (self){
        //----------------------
        // Initialize file storage
        //----------------------
        self.containerURL =
        [self URLForUbiquityContainerIdentifier:nil];
        
        //----------------
        // Refresh the iCloud drive
        //----------------
        [self startDownloadingUbiquitousItemAtURL:self.containerURL error:nil] ;
        
        self.directorPartialPath = @"";
        
        [self initICloudContainer];
    }
    return self;
}

+(MyFileManager*)sharedManager{
    static MyFileManager *sharedMyFileManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyFileManager = [[MyFileManager alloc] init];
    });
    return sharedMyFileManager;
}

- (bool)initICloudContainer{
    BOOL result = NO;
    
    // Check two directories: test and study
    [self checkDirectorExistAndCreate:@"test"];
    [self checkDirectorExistAndCreate:@"study"];
    
    self.directorPartialPath = @"test";
    return result;
}

// setting to make sure a directory exists
-(void)setDirectorPartialPath:(NSString *)directorPartialPath{
    [self checkDirectorExistAndCreate:directorPartialPath];
    _directorPartialPath = directorPartialPath;
}

- (NSString*)currentFullDirectoryPath{
    return  [[self.containerURL path]
     stringByAppendingPathComponent:self.directorPartialPath];
}

-(NSURL*)currentFullDirectoryURL{
    return [self.containerURL URLByAppendingPathComponent:self.directorPartialPath];
}

// Check if a directory exists. If not, create one.
- (bool)checkDirectorExistAndCreate:(NSString*) relativeDirPath{
    BOOL result = NO;
    BOOL isDirectory = NO;
    BOOL mustCreateDocumentsDirectory = NO;
    
    
    NSString *myDirectory = [[self.containerURL path]
                                   stringByAppendingPathComponent:relativeDirPath];
    
    if ([self fileExistsAtPath:myDirectory
                   isDirectory:&isDirectory]){
        if (isDirectory == NO){
            mustCreateDocumentsDirectory = YES;
        }
    } else {
        mustCreateDocumentsDirectory = YES;
    }
    
    if (mustCreateDocumentsDirectory){
        NSLog(@"Must create %@.", myDirectory);
        
        NSError *directoryCreationError = nil;
        
        if ([self createDirectoryAtPath:myDirectory
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:&directoryCreationError])
        {
            result = YES;
            NSLog(@"Successfully created %@.", myDirectory);
        } else {
            NSLog(@"Failed to create %@ with error = %@", myDirectory,
                  directoryCreationError);
        }
        
    } else {
//        NSLog(@"%@ already exists.", myDirectory);
        result = YES;
    }
    return result;
}

@end
