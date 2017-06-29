//
//  MapInformationSheet.h
//  NavTools
//
//  Created by Daniel on 2/1/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SpatialEntity;

@interface MapInformationSheet : UIView <UITextFieldDelegate>

@property SpatialEntity *spatialEntity;

-(void)addSheetForEntity:(SpatialEntity*)entity;
-(void)removeSheet;

-(void)updateSheet;

@end
