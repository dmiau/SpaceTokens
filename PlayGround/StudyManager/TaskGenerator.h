//
//  TaskGenerator.h
//  SpaceBar
//
//  Created by dmiau on 9/26/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskGenerator : NSObject

+(TaskGenerator*)sharedManager;

- (NSMutableArray*)generateTasks;

@end
