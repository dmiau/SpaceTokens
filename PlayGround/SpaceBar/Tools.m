//
//  Tools.m
//  SpaceBar
//
//  Created by Daniel on 2/3/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "Tools.h"
#import <UIKit/UIKit.h>

//-----------------
// A queue-like structure
//-----------------
@implementation NSMutableArray (QueueAdditions)

- (id) Queue_dequeueReusableObjOfClass: (NSString*) classString {
    
    // This method only works for UIControl derived class
    if (![[NSClassFromString(classString) class] isSubclassOfClass:[UIControl class]])
    {
        NSException *exception = [[NSException alloc ]initWithName:@"Custom Exception" reason:@"This method only works for UIControl derived class." userInfo:@{@"Localized key": @"Unknown Class Name"}];
        
        [exception raise];
    }
    
    id object = nil;
    
    // Check if an unused object exist
    NSPredicate *classPredicate = [NSPredicate predicateWithFormat:
                               @"SELF isMemberOfClass: %@", [NSClassFromString(classString) class]];

    NSPredicate *viewPredicate = [NSPredicate predicateWithFormat:
                                  @"SELF.superview = nil"];
    
    NSArray *predicateResults = [self filteredArrayUsingPredicate:classPredicate];
    
    NSArray *finalPredicateResults = [predicateResults filteredArrayUsingPredicate:viewPredicate];
    
    if ([finalPredicateResults count] == 0){

        // Create a new one if there is none
        object = [[NSClassFromString(classString) alloc] init];
        
        // Throw an exception if the object does not exist
        if (!object){
            NSException *exception = [[NSException alloc ]initWithName:@"Custom Exception" reason:@"Custom Reason" userInfo:@{@"Localized key": @"Unknown Class Name"}];
            [exception raise];
        }
        
        // Store the object into the array
        [self addObject:object];
        
    }else{
        object = finalPredicateResults[0];
    }
    
    return object;
}

@end
