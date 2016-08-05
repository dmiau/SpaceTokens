//
//  RouteDatabase.h
//  SpaceBar
//
//  Created by Daniel on 8/4/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Route.h"

@interface RouteDatabase : NSObject
@property NSString *name;
@property NSMutableArray <Route *> *routeArray;

-(void)reloadRouteDB; // a temporary method

// iCloud related methods
-(bool)saveDatatoFileWithName: (NSString*) fullPathFileName;
-(bool)loadFromFile:(NSString*) fullPathFileName;
@end
