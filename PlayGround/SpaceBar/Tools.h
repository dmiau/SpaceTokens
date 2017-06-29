//
//  Tools.h
//  NavTools
//
//  Created by Daniel on 2/3/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (QueueAdditions)


- (id) Queue_dequeueReusableObjOfClass: (NSString*) classString;
@end
