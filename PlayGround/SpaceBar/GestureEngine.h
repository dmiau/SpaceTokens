//
//  GestureEngine.h
//  NavTools
//
//  Created by Daniel on 8/2/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NavTools;

@interface GestureEngine : UIControl

@property NavTools *spaceBar;


- (id)initWithSpaceBar:(NavTools*) spaceBar;

@end
