//
//  POIDatabase.h
//  SpaceBar
//
//  Created by dmiau on 7/20/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "POI.h"

@interface POIDatabase : NSObject{
    NSMutableArray <POI *> *cachedDefaultPOIArray;
    BOOL useDefaultPOIArray;
}
@property NSString *name;
@property NSMutableArray <POI *> *poiArray;

+(POIDatabase*)sharedManager;

// temp POI array
- (void)useTempPOIArray:(NSMutableArray*)tempArray;
- (void)removeTempPOIArray;

// iCloud related methods
- (void)debugInit; // a temporary method
-(bool)saveDatatoFileWithName: (NSString*) fullPathFileName;
-(bool)loadFromFile:(NSString*) fullPathFileName;
@end
