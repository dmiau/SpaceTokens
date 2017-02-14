//
//  StarIconGenerator.h
//  lab_ImageGeneration
//
//  Created by Daniel on 2/10/17.
//  Copyright © 2017 Daniel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IconGenerator.h"

typedef enum {YELLOWSTAR, REDSTAR} STARSTYLE;

@interface StarIconGenerator : IconGenerator
@property STARSTYLE starStyle;
@property BOOL isDotOn;

@end
