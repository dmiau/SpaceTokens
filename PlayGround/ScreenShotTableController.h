//
//  ScreenShotTableController.h
//  NavTools
//
//  Created by Daniel on 6/29/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ViewController;

@interface ScreenShotTableController : UIViewController
<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
{
    NSArray *fileArray;
}

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property ViewController* rootViewController;
- (IBAction)reloadICloud:(id)sender;

@end
