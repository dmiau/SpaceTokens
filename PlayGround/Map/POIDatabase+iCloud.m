//
//  POIDatabase+iCloud.m
//  SpaceBar
//
//  Created by dmiau on 7/31/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "POIDatabase+iCloud.h"

@implementation POIDatabase (iCloud)


// Good reference: http://www.idev101.com/code/Objective-C/Saving_Data/NSKeyedArchiver.html

- (bool)saveDatatoFileWithName: (NSString*) fileName{
    
    // Test a data save
    NSString *pathToSave = [self.documentDirectory
     stringByAppendingPathComponent:fileName];
    
    // Save the entire database to a file
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject: self];
    
    if ([data writeToFile:pathToSave atomically:YES]){
        NSLog(@"File saving successfully!");
        return YES;
    }else{
        NSLog(@"File saving failed!");
        return NO;
    }
}

- (bool)loadFromFile:(NSString*) fileName{
        
    // Read content from a file
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *pathToRead =
    [self.documentDirectory stringByAppendingPathComponent:fileName];
    
    if ([fileManager fileExistsAtPath:pathToRead]){

        NSData *data = [NSData dataWithContentsOfFile:pathToRead];
        POIDatabase *poiDB = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        self.poiArray = poiDB.poiArray;
        return YES;
    }else{
        NSLog(@"file does not exist.");
        return NO;
    }
}

@end
