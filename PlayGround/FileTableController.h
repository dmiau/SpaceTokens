//
//  FileTableController.h
//  NavTools
//
//  Created by Daniel on 8/1/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ViewController;

@interface FileTableController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>{
    NSArray *fileArray;
}

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property ViewController* rootViewController;
- (IBAction)reloadICloud:(id)sender;

@end
