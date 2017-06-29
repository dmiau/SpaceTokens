//
//  GestureEngine.h
//  NavTools
//
//  Created by Daniel on 8/2/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SpaceBar;

@interface GestureEngine : UIControl

@property SpaceBar *spaceBar;


- (id)initWithSpaceBar:(SpaceBar*) spaceBar;

@end
