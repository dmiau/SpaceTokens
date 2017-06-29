//
//  DiskGenerator.h
//  NavTools
//
//  Created by dmiau on 2/12/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IconGenerator.h"

typedef enum {REDDISK, GRAYDISK} DISKSTYLE;

@interface DiskGenerator : IconGenerator

@property DISKSTYLE diskStyle;


@end
