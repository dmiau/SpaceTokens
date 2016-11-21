//
//  TaskGenerator.h
//  SpaceBar
//
//  Created by dmiau on 9/26/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SnapshotPlace;
@class SnapshotAnchorPlus;
@class POI;

@interface TaskGenerator : NSObject

+(TaskGenerator*)sharedManager;
- (NSMutableArray*)generateTasks;

//--------------
// Private methods
//--------------

- (POI*)p_generateTargetForReferencePOI: (POI*) tokenPOI withAngle: (double)degree offSetDistance: (double) offset;

- (NSMutableDictionary<NSString*, SnapshotPlace*> * )p_generatePlaceDictionary;

- (NSMutableDictionary<NSString*, SnapshotAnchorPlus*> * )p_generateAnchorPlusDictionary;


@end
