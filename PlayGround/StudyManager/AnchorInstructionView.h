//
//  AnchorInstructionView.h
//  NavTools
//
//  Created by Daniel on 12/21/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SnapshotAnchorPlus;

@interface AnchorInstructionView : UIView{
    SnapshotAnchorPlus *mySnapShotAnchor;
}

@property (weak, nonatomic) IBOutlet UITextView *instructionTextField;
@property (weak, nonatomic) IBOutlet UILabel *demoBanner;

- (void)prepareInstruction:(SnapshotAnchorPlus*) snapShotAnchor;
- (void)showInstruction;

- (IBAction)okTapped:(id)sender;

@end
