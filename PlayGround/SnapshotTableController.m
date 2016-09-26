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
#import "SnapshotDatabase.h"
#import "StudyManager/GameManager.h"
#import "MyFileManager.h"
#import "SnapshotDetailViewController.h"


@implementation SnapshotTableController

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
        
        snapshotDatabase = [SnapshotDatabase sharedManager];
    }
    return self;
}

- (void)awakeFromNib{
    
}

- (void)viewWillAppear:(BOOL)animated{
    // Regenerate the gameVector for now
    [self.myTableView reloadData];
}

#pragma mark -----Table View Data Source Methods-----
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Three sections: user location, the location file listing, and bookmarks
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [snapshotDatabase.snapshotArray count];
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
    cell.textLabel.text = snapshotDatabase.snapshotArray[i].name;
    return cell;
}


#pragma mark -----Table Interaction Methods-----
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)path {
    GameManager *gameManager = [GameManager sharedManager];
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

//----------------
// This method is called when the accessory button is pressed
// *************
// It appears that this method will only be called when
// accessoryTrype is set to "Detail Disclosure"
//----------------
- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    // Get the row ID
    int i = [indexPath row];
    int section_id = [indexPath section];
    
    Snapshot *aSnapshot = snapshotDatabase.snapshotArray[i];
    // Perform segue
    [self performSegueWithIdentifier:@"SnapshotDetailVC"
                              sender:aSnapshot];
}


//-------------
// Deleting rows
//-------------
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //https://developer.apple.com/library/ios/documentation/userexperience/conceptual/tableview_iphone/ManageInsertDeleteRow/ManageInsertDeleteRow.html
    
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        int i = [indexPath row];
        
        // Remove the snapshot from the gameVector
        [snapshotDatabase.snapshotArray removeObject: snapshotDatabase.snapshotArray[i]];
        
        // Then, delete the row
        [self.myTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                withRowAnimation:UITableViewRowAnimationFade];
    }
}

//----------------
// Reorder the cell
//----------------
- (IBAction)editAction:(UIButton *)button {
    
    if ([button.titleLabel.text isEqualToString:@"Edit"]){
        [self.myTableView setEditing:YES animated:YES];
        [button setTitle:@"Done" forState:UIControlStateNormal];
    }else{
        [self.myTableView setEditing:NO animated:YES];
        [button setTitle:@"Edit" forState:UIControlStateNormal];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    // Get the object
    Snapshot *snapshot = snapshotDatabase.snapshotArray[sourceIndexPath.row];
    [snapshotDatabase.snapshotArray removeObjectAtIndex:sourceIndexPath.row];
    [snapshotDatabase.snapshotArray insertObject:snapshot
                                         atIndex:destinationIndexPath.row];
}


#pragma mark -----Navigation and Exit-----
//------------------
// Prepare for the detail view
//------------------
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(Snapshot*)sender
{
    if ([segue.identifier isEqualToString:@"SnapshotDetailVC"])
    {
        SnapshotDetailViewController *destinationViewController =
        segue.destinationViewController;
        
        // grab the annotation from the sender
        destinationViewController.snapshot = sender;
    }
}

#pragma mark --Task Generation--
- (IBAction)generateTaskAction:(id)sender {
    // Generate new tasks
    [snapshotDatabase generateNewTasks];
    
    // Refresh the table
    [self.myTableView reloadData];    
}

#pragma mark --Save/Reload--
- (IBAction)saveAction:(id)sender {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        MyFileManager *myFileManager = [MyFileManager sharedManager];
        
        NSString *dirPath = [myFileManager currentFullDirectoryPath];
        NSString *fileFullPath = [dirPath stringByAppendingPathComponent:@"mySnapshotDB.snapshot"];
        
        // Test file saving capability
        [snapshotDatabase saveDatatoFileWithName:fileFullPath];
    });
}

- (IBAction)reloadAction:(id)sender {
    MyFileManager *myFileManager = [MyFileManager sharedManager];
    
    NSString *dirPath = [myFileManager currentFullDirectoryPath];
    NSString *fileFullPath = [dirPath stringByAppendingPathComponent:@"mySnapshotDB.snapshot"];
    
    [snapshotDatabase loadFromFile:fileFullPath];

    [self.myTableView reloadData];
}

@end
