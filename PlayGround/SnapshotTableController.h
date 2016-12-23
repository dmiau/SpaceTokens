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
    NSArray *snapshotFileArray;
    
    //this flag decides whether the snapshot file section should be expanded or collapsed
    bool expandCollectionSection;
    
}

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property ViewController* rootViewController;

@property (weak, nonatomic) IBOutlet UISwitch *studyOutlet;
- (IBAction)studyAction:(id)sender;

- (IBAction)saveAction:(id)sender;
- (IBAction)reloadAction:(id)sender;

- (IBAction)editAction:(UIBarButtonItem*)sender;
- (IBAction)generateTaskAction:(id)sender;

@end
