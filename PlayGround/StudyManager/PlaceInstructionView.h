//
//  PlaceInstructionView.h
//  lab_Drawing
//
//  Created by Daniel on 11/9/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import <UIKit/UIKit.h>


@class SnapshotPlace;

@interface PlaceInstructionView : UIView{
    SnapshotPlace *mySnapShotPlace;
}

- (void)prepareInstruction:(SnapshotPlace*) snapShotPlace;
- (void)showInstruction;

@property (weak, nonatomic) IBOutlet UITextView *instructionLabel;
@property (weak, nonatomic) IBOutlet UILabel *demoBanner;

- (IBAction)okTapped:(id)sender;

@end
