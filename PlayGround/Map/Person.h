//
//  Person.h
//  SpaceBar
//
//  Created by dmiau on 8/23/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "POI.h"

@interface Person : NSObject <CLLocationManagerDelegate>

@property BOOL updateFlag;
@property POI *poi;

@end
