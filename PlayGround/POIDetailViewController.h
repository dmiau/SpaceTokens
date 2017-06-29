//
//  POIDetailViewController.h
//  NavTools
//
//  Created by dmiau on 9/2/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpatialEntity.h"

@interface POIDetailViewController : UIViewController

@property SpatialEntity *spatialEntity;
@property (weak, nonatomic) IBOutlet UITextField *nameOutlet;


@end
