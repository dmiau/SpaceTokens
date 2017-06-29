//
//  PlaceTaskGenerator.h
//  NavTools
//
//  Created by Daniel on 12/20/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomMKMapView.h"

@class SnapshotPlace;

@interface PlaceTaskGenerator : NSObject

@property int randomSeed;
@property int taskNumber;
@property int baseDistanceInPixel;
@property MKCoordinateRegion initRegion;
@property NSString* dataSetID;

- (NSMutableDictionary<NSString*, SnapshotPlace*> * )generateSnapshotDictionary;

@end
