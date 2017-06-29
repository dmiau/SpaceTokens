//
//  LocationTableController.h
//  NavTools
//
//  Created by Daniel on 7/18/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ViewController;
@class EntityDatabase;

@interface LocationTableController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>{
    EntityDatabase *entityDatabase;
    NSArray *entityFileArray;
    
    //this flag decides whether the snapshot file section should be expanded or collapsed
    bool expandCollectionSection;
}

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property ViewController* rootViewController;
@property (weak, nonatomic) IBOutlet UIButton *editOutlet;

- (IBAction)saveAction:(id)sender;
- (IBAction)reloadAction:(id)sender;
- (IBAction)newFileAction:(id)sender;
- (IBAction)saveAsAction:(id)sender;

- (IBAction)editAction:(id)sender;

@end
