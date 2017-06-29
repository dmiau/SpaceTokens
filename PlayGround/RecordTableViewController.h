//
//  RecordTableViewController.h
//  NavTools
//
//  Created by Daniel on 9/19/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RecordDatabase;

@interface RecordTableViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>{
    RecordDatabase *recordDatabase;
    NSArray *allKeys; // Cache all the keys
}

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
- (IBAction)saveAction:(id)sender;
- (IBAction)reloadAction:(id)sender;

@end
