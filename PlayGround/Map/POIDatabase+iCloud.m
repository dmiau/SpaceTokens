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

- (bool)saveDatatoFileWithName: (NSString*) fullPathFileName{
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

- (bool)loadFromFile:(NSString*) fullPathFileName{
        
    // Read content from a file
    NSFileManager *fileManager = [NSFileManager defaultManager];    
    if ([fileManager fileExistsAtPath:fullPathFileName]){

        NSData *data = [NSData dataWithContentsOfFile:fullPathFileName];
        POIDatabase *poiDB = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        self.name = poiDB.name;
        self.poiArray = poiDB.poiArray;
        return YES;
    }else{
        NSLog(@"%@ does not exist.", fullPathFileName);
        return NO;
    }
}

@end
