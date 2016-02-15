//
//  Constants.h
//  SpaceBar
//
//  Created by dmiau on 2/13/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#ifndef Constants_h
#define Constants_h
#import <Foundation/Foundation.h>

// This file defines all the constants

// http://stackoverflow.com/questions/538996/constants-in-objective-c

// Types of notifications:
FOUNDATION_EXPORT NSString *const AddToDisplaySetNotification;
FOUNDATION_EXPORT NSString *const RemoveFromDisplaySetNotification;
FOUNDATION_EXPORT NSString *const AddToTouchingSetNotification;
FOUNDATION_EXPORT NSString *const RemoveFromTouchingSetNotification;
FOUNDATION_EXPORT NSString *const AddToDraggingSetNotification;
FOUNDATION_EXPORT NSString *const RemoveFromDraggingSetNotification;

#endif /* Constants_h */
