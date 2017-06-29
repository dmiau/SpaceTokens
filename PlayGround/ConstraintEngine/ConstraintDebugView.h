//
//  ConstraintDebugView.h
//  NavTools
//
//  Created by Daniel on 11/7/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpeechEngine.h"

@interface ConstraintDebugView : UIView

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;

@property (weak) SpeechEngine *speechEngine;

- (IBAction)recordButtonTapped:(id)sender;
- (IBAction)dismissButtonTapped:(id)sender;

@end
