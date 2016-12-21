//
//  AnchorInstructionView.h
//  SpaceBar
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

- (void)prepareInstruction:(SnapshotAnchorPlus*) snapShotAnchor;
- (void)showInstruction;

- (IBAction)okTapped:(id)sender;

@end
