//
//  POIDatabase.h
//  SpaceBar
//
//  Created by dmiau on 7/20/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "POI.h"

@interface POIDatabase : NSObject


@property NSMutableArray <POI *> *poiArray;

-(void)reloadPOI; // a temporary method
@end
