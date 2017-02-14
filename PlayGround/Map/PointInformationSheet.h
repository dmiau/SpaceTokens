//
//  PointInformationSheet.h
//  SpaceBar
//
//  Created by dmiau on 2/9/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "MapInformationSheet.h"

@interface PointInformationSheet : MapInformationSheet

@property (weak, nonatomic) IBOutlet UITextField *titleOutlet;
@property (weak, nonatomic) IBOutlet UITextView *detailTextView;

// star button
@property (weak, nonatomic) IBOutlet UIButton *starOutlet;
- (IBAction)starAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *tokenButtonOutlet;

- (IBAction)tokenButtonAction:(id)sender;


@end
