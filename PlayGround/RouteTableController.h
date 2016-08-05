//
//  RouteTableController.h
//  SpaceBar
//
//  Created by Daniel on 8/5/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ViewController;

@class RouteDatabase;

@interface RouteTableController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property ViewController* rootViewController;

- (IBAction)saveAction:(id)sender;

- (IBAction)reloadAction:(id)sender;

- (IBAction)clearAction:(id)sender;

@end
