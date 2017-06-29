//
//  CollectionInformationSheet.h
//  NavTools
//
//  Created by dmiau on 2/9/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "MapInformationSheet.h"

@interface CollectionInformationSheet : MapInformationSheet

@property (weak, nonatomic) IBOutlet UITextField *titleOutlet;
@property (weak, nonatomic) IBOutlet UITextView *detailTextView;
@property (weak, nonatomic) IBOutlet UITextView *quickInfoOutlet;

// star button
@property (weak, nonatomic) IBOutlet UIButton *starOutlet;
- (IBAction)starAction:(id)sender;




// Collection Segment Control
@property (weak, nonatomic) IBOutlet UISegmentedControl *collectionModeOutlet;
- (IBAction)collectionModeAction:(id)sender;

@end
