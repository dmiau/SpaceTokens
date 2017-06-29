  //
//  AdditionTool.h
//  NavTools
//
//  Created by Daniel on 1/13/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SpaceToken;

@interface AdditionTool : UIView

@property (nonatomic, copy) BOOL (^additionHandlingBlock)(SpaceToken*);
@property id home; // This is to test if any of the tokens related to the home structure is touched
@end
