//
//  MapInformationSheet.h
//  SpaceBar
//
//  Created by Daniel on 2/1/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SpatialEntity;

@interface MapInformationSheet : UIView <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleOutlet;
@property (weak, nonatomic) IBOutlet UITextView *detailTextView;

@property SpatialEntity *spatialEntity;

-(void)addSheetForEntity:(SpatialEntity*)entity;
-(void)removeSheet;

// star button
@property (weak, nonatomic) IBOutlet UIButton *starOutlet;
- (IBAction)starAction:(id)sender;

@end
