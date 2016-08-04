//
//  LocationTableController.h
//  SpaceBar
//
//  Created by Daniel on 7/18/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ViewController;


@interface LocationTableController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>{
    NSArray *fileArray;
}

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property ViewController* rootViewController;
@end
