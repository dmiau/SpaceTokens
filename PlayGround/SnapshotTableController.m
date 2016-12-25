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
#import "TaskGenerator.h"
#import "GameManager.h"

@implementation SnapshotTableController

#pragma mark -- Initialization --
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
     
        // Collapse the collection by default
        expandCollectionSection = false;
        
        snapshotDatabase = [SnapshotDatabase sharedManager];
    }
    return self;
}

- (void)awakeFromNib{
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    // Collect a list of .snapshot files
    [self updateSnapshotFileList];
    
    // Regenerate the gameVector for now
    [self.myTableView reloadData];
}

- (void)updateSnapshotFileList{
    // List all the files in the document direction
    NSArray *fileArray = [[NSFileManager defaultManager]
                 contentsOfDirectoryAtPath:
                 [self.rootViewController.myFileManager currentFullDirectoryPath] error:NULL];
    
    // List all the files with the .snapshot extention
    snapshotFileArray = [fileArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self CONTAINS '.snapshot'"]];
}



#pragma mark -----Table View Data Source Methods-----
typedef enum {COLLECTIONS, SNAPSHOTS} sectionEnum;


//-----------------
// Section
//-----------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section ==COLLECTIONS){
        if (expandCollectionSection)
            return [snapshotFileArray count];
        else
            return 0;
    }else{
        return [snapshotDatabase.snapshotArray count];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Three sections: user location, the location file listing, and bookmarks
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *list = @[@"Snapshot files", snapshotDatabase.currentFileName];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 30)];
    [label setFont:[UIFont boldSystemFontOfSize:14]];
    NSString *string =[list objectAtIndex:section];
    /* Section header is in 0th index... */
    [label setText:string];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithRed:166/255.0 green:177/255.0 blue:186/255.0 alpha:1.0]]; //your background color...
    
    // Only add gesture recognizer to the AREA section
    if (section == COLLECTIONS){
        // Add UITapGestureRecognizer to SectionView
        UITapGestureRecognizer *headerTapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionHeaderTapped:)];
        [view addGestureRecognizer:headerTapped];
    }
    
    /********** Add a custom Separator with cell *******************/
    UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 29, self.myTableView.frame.size.width, 1)];
    separatorLineView.backgroundColor = [UIColor blackColor];
    [view addSubview:separatorLineView];
    
    return view;
}


// To handle the section header tapping gesture
- (void)sectionHeaderTapped:(UITapGestureRecognizer *)gestureRecognizer{
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0
                                                inSection:gestureRecognizer.view.tag];
    if (indexPath.row == 0) {
        [self updateSnapshotFileList];
        expandCollectionSection = !expandCollectionSection;
        [self.myTableView reloadData];
    }
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
    
    if (section_id == COLLECTIONS){
        cell.textLabel.text = snapshotFileArray[i];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", i];
    }else{
        // Configure Cell
        Snapshot *aSnapshot = snapshotDatabase.snapshotArray[i];
        cell.textLabel.text = aSnapshot.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", i];
        
        if (aSnapshot.record.isAnswered){
            [cell setBackgroundColor:[UIColor greenColor]];
        }else{
            [cell setBackgroundColor:[UIColor whiteColor]];
        }        
    }
    
    return cell;
}


#pragma mark -----Table Interaction Methods-----
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)path {
    GameManager *gameManager = [GameManager sharedManager];
    
    int row_id = [path row];
    int section_id = [path section];
    
    if (section_id == COLLECTIONS){
        //----------------
        // User selects a file
        //----------------
        MyFileManager *myFileManager = [MyFileManager sharedManager];
        
        NSString *dirPath = [myFileManager currentFullDirectoryPath];
        NSString *fileFullPath = [dirPath stringByAppendingPathComponent:snapshotFileArray[row_id]];
        [snapshotDatabase loadFromFile:fileFullPath];
        gameManager.snapshotDatabase = snapshotDatabase;
        expandCollectionSection = false;
        [self.myTableView reloadData];
        
    }else{
        
        if ([GameManager sharedManager].gameManagerStatus == OFF){
            [GameManager sharedManager].gameManagerStatus = DEMO;
        }
        // execute the snapshot
        [gameManager runSnapshotIndex:row_id];
        //--------------
        // We might need to do something for iPad
        //--------------
        [self.navigationController popViewControllerAnimated:NO];
    }
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
    
    if (section_id ==COLLECTIONS){
    }else{
        Snapshot *aSnapshot = snapshotDatabase.snapshotArray[i];
        // Perform segue
        [self performSegueWithIdentifier:@"SnapshotDetailVC"
                                  sender:aSnapshot];
    }
}


//-------------
// Deleting rows
//-------------
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //https://developer.apple.com/library/ios/documentation/userexperience/conceptual/tableview_iphone/ManageInsertDeleteRow/ManageInsertDeleteRow.html
    
        int section_id = [indexPath section];
        if (section_id == COLLECTIONS){
            //-----------------------
            // Delete a snapshot file
            //-----------------------
            
            int i = [indexPath row];
            if ([snapshotFileArray[i] isEqualToString:@"default.snapshot"])
                return;
            
            MyFileManager *myFileManager = [MyFileManager sharedManager];
            
            NSString *dirPath = [myFileManager currentFullDirectoryPath];
            NSString *fileFullPath = [dirPath stringByAppendingPathComponent: snapshotFileArray[i]];
            
            // delete a file
            [myFileManager removeItemAtPath:fileFullPath error:nil];
            
            [self updateSnapshotFileList];
            [self.myTableView reloadData];
        }else{
            //-----------------------
            // Delete a snapshot
            //-----------------------
            
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
    

}

//----------------
// Reorder the cell
//----------------
- (IBAction)editAction:(UIBarButtonItem*) button {
    
    if ([button.title isEqualToString:@"Edit"]){
        [self.myTableView setEditing:YES animated:YES];
        [button setTitle:@"Done"];
    }else{
        [self.myTableView setEditing:NO animated:YES];
        [button setTitle:@"Edit"];
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
    [[TaskGenerator sharedManager] generateTaskFiles:5];
    
    // Refresh the table
    [self.myTableView reloadData];    
}

#pragma mark --Save/Reload--
- (IBAction)studyAction:(UISwitch*)sender {
    if (sender.isEnabled){
        [GameManager sharedManager].snapshotDatabase = snapshotDatabase;
        [GameManager sharedManager].gameManagerStatus = STUDY;
    }else{
        [GameManager sharedManager].gameManagerStatus = OFF;
    }
}

- (IBAction)saveAction:(id)sender {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        MyFileManager *myFileManager = [MyFileManager sharedManager];
        
        NSString *dirPath = [myFileManager currentFullDirectoryPath];
        NSString *fileFullPath =
        [dirPath stringByAppendingPathComponent:snapshotDatabase.currentFileName];
        
        // Test file saving capability
        [snapshotDatabase saveDatatoFileWithName:fileFullPath];
    });
}

- (IBAction)reloadAction:(id)sender {
    MyFileManager *myFileManager = [MyFileManager sharedManager];
    
    NSString *dirPath = [myFileManager currentFullDirectoryPath];
    NSString *fileFullPath = [dirPath stringByAppendingPathComponent:snapshotDatabase.currentFileName];
    
    [snapshotDatabase loadFromFile:fileFullPath];

    [self.myTableView reloadData];
}

@end
