//
//  AnchorTaskGenerator.h
//  NavTools
//
//  Created by dmiau on 12/19/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomMKMapView.h"

@class SnapshotAnchorPlus;

@interface AnchorTaskGenerator : NSObject

@property int randomSeed;
@property int taskNumber;
@property int baseDistanceInPixel;
@property MKCoordinateRegion initRegion;
@property NSString* dataSetID;

- (NSMutableDictionary<NSString*, SnapshotAnchorPlus*> * )generateSnapshotDictionary;

@end
