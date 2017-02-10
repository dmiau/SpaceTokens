//
//  InformationSheetManager.h
//  SpaceBar
//
//  Created by dmiau on 2/9/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SpatialEntity;
@class MapInformationSheet;

@interface InformationSheetManager : NSObject

@property MapInformationSheet *activeSheet;

-(void)addSheetForEntity:(SpatialEntity*)entity;
-(void)removeSheet;
@end
