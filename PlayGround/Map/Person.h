//
//  Person.h
//  NavTools
//
//  Created by dmiau on 8/23/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "POI.h"

@interface Person : POI <CLLocationManagerDelegate>

@property double headingInDegree;
@property BOOL updateFlag;

@end
