//
//  DirectionPanel.h
//  NavTools
//
//  Created by dmiau on 7/12/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "topPanel.h"

@class ViewController;

//---------------
// Direction panel
//---------------
@interface DirectionPanel : UIView <TopPanel>

@property ViewController *rootViewController;

@end
