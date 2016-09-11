//
//  POIDetailViewController.h
//  SpaceBar
//
//  Created by dmiau on 9/2/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Map/POI.h"

@interface POIDetailViewController : UIViewController

@property POI *poi;
@property (weak, nonatomic) IBOutlet UITextField *nameOutlet;


@end
