//
//  SnapshotDetailViewController.h
//  SpaceBar
//
//  Created by dmiau on 9/12/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnapshotProtocol.h"

@interface SnapshotDetailViewController : UIViewController

@property Snapshot* snapshot;
@property (weak, nonatomic) IBOutlet UITextField *nameOutlet;

@end
