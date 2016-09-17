//
//  SnapshotTableController.h
//  SpaceBar
//
//  Created by Daniel on 8/6/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ViewController;
@class SnapshotDatabase;

@interface SnapshotTableController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>{
    SnapshotDatabase *snapshotDatabase;
}

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property ViewController* rootViewController;

- (IBAction)saveAction:(id)sender;
- (IBAction)reloadAction:(id)sender;
- (IBAction)editAction:(UIButton *)sender;

@end
