//
//  Route+Tools.m
//  SpaceBar
//
//  Created by Daniel on 11/21/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "Route+Tools.h"
#import "POI.h"
#import "EntityDatabase.h"
#import "TokenCollectionView.h"

@implementation Route (Tools)

+ (void) addRouteWithSource:(POI*) source Destination:(POI*) destination
{
    
    Route *aRoute = [[Route alloc] init];
    void(^completionBlock)(void) = ^{
        // Push the newly created route into the entity database
        EntityDatabase *entityDatabase = [EntityDatabase sharedManager];
        [entityDatabase.entityArray addObject:aRoute];
        aRoute.isMapAnnotationEnabled = YES;
        NSLog(@"Direction response received!");
        NSLog(@"Rooute: %@ added.", aRoute.name);
        
        // Update the collection view
        [[TokenCollectionView sharedManager] addItemFromBottom:aRoute];
    };
    aRoute.routeReadyBlock = completionBlock;
    [aRoute requestRouteWithSource:source Destination:destination];
}


+ (Route*) createRouteFromEntities: (NSArray *)entityArray{
    Route *aRoute = [[Route alloc] init];
    
    
    
    
    return aRoute;
}


@end
