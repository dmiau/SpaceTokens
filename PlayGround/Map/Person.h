//
//  Person.h
//  SpaceBar
//
//  Created by dmiau on 8/23/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpatialEntity.h"

@interface Person : SpatialEntity <CLLocationManagerDelegate>

@property double headingInDegree;
@property BOOL updateFlag;

@end
