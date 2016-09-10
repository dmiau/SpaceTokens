//
//  SnapshotTableController.m
//  SpaceBar
//
//  Created by Daniel on 8/6/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SnapshotTableController.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "StudyManager/SnapshotDatabase.h"
#import "StudyManager/GameManager.h"

@implementation SnapshotTableController{
    GameManager *gameManager;
}

// Initialization
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self){
        
        // Connect to the parent view controller to update its
        // properties directly
        
        //-------------------
        // Set the rootViewController
        //-------------------
        AppDelegate *app = [[UIApplication sharedApplication] delegate];
        
        UINavigationController *myNavigationController =
        app.window.rootViewController;
        self.rootViewController = [myNavigationController.viewControllers objectAtIndex:0];
        
        // Connect the RouteDatabase
        gameManager = self.rootViewController.gameManager;
    }
    return self;
}

- (void)awakeFromNib{
    
}

- (void)viewWillAppear:(BOOL)animated{
    // Regenerate the gameVector for now
    gameManager.gameVector = [gameManager.snapshotDatabase.snapshotDictrionary allKeys];    
    [self.myTableView reloadData];
}

#pragma mark -----Table View Data Source Methods-----
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Three sections: user location, the location file listing, and bookmarks
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [gameManager.gameVector count];
}

//----------------
// Populate each row of the table
//----------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView                                                dequeueReusableCellWithIdentifier:@"snapshotCell"];
    
    if (cell == nil){
        NSLog(@"Something wrong...");
    }
    // Get the row ID
    int section_id = [indexPath section];
    int i = [indexPath row];
    
    // Configure Cell
    cell.textLabel.text = gameManager.gameVector[i];
    return cell;
}


#pragma mark -----Table Interaction Methods-----
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)path {
    
    // Enable the study interface if it is not already enabled
    if (gameManager.gameManagerStatus != STUDY){
        gameManager.gameManagerStatus = STUDY;
    }
    
    int row_id = [path row];
    int section_id = [path section];

    // execute the snapshot
    [gameManager runSnapshotIndex:row_id];
    //--------------
    // We might need to do something for iPad
    //--------------
    [self.navigationController popViewControllerAnimated:NO];
}

@end
