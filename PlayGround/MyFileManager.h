//
//  MyFileManager.h
//  SpaceBar
//
//  Created by dmiau on 8/3/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyFileManager : NSFileManager

@property NSURL *containerURL;
@property NSString *directorPartialPath;

- (NSString*)currentFullDirectoryPath; // Returns the full directory string
- (NSURL*)currentFullDirectoryURL; // Returns the full directory URL
@end
