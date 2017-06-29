//
//  ScreenShotTableController.m
//  SpaceBar
//
//  Created by Daniel on 6/29/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "ScreenShotTableController.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "ImageViewController.h"

@interface ScreenShotTableController ()

@end

@implementation ScreenShotTableController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    }
    return self;
}

- (void)awakeFromNib{
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [self initFileList];
    [self.myTableView reloadData];
}

- (void) initFileList{
    // List all the files in the document direction
    fileArray = [[NSFileManager defaultManager]
                 contentsOfDirectoryAtPath:
                 [self.rootViewController.myFileManager currentFullDirectoryPath] error:NULL];
    
    // List all the files with the .snapshot extention
    fileArray = [fileArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self CONTAINS '.png'"]];
    
}

#pragma mark -----Table View Data Source Methods-----
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Three sections: user location, the location file listing, and bookmarks
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [fileArray count];
}

//----------------
// Populate each row of the table
//----------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView                                                dequeueReusableCellWithIdentifier:@"fileCell"];
    
    if (cell == nil){
        NSLog(@"Something wrong...");
    }
    // Get the row ID
    int section_id = [indexPath section];
    int i = [indexPath row];
    
    // Configure Cell
    cell.textLabel.text = fileArray[i];
    return cell;
}



// MARK: -----Table Interaction Methods-----
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    int row_id = [path row];
//    int section_id = [path section];
//    
//    if (section_id == COLLECTIONS){
//        //----------------
//        // User selects a file
//        //----------------
//        MyFileManager *myFileManager = [MyFileManager sharedManager];
//        
//        NSString *dirPath = [myFileManager currentFullDirectoryPath];
//        NSString *fileFullPath = [dirPath stringByAppendingPathComponent:entityFileArray[row_id]];
//        [entityDatabase loadFromFile:fileFullPath];
//        expandCollectionSection = false;
//        [self.myTableView reloadData];
//        
//    }else if (section_id == ENTITIES){
//        // Get the selected entity
//        SpatialEntity *entity = [[EntityDatabase sharedManager] getEntityArray][row_id];
//        
//        CustomMKMapView *mapView = [CustomMKMapView sharedManager];
//        
//        [[CustomMKMapView sharedManager] snapOneCoordinate:entity.latLon
//                                                      toXY:CGPointMake(mapView.frame.size.width/2, mapView.frame.size.height/2)
//                                                  animated:NO];
//        
//        [[HighlightedEntities sharedManager] clearHighlightedSet];
//        [[HighlightedEntities sharedManager] addEntity:entity];
//        
//        [self.navigationController popViewControllerAnimated:NO];
//    }
    
    // Get the row ID
    int i = [indexPath row];
    int section_id = [indexPath section];
    
    // Load the image
    MyFileManager *myFileManager = [MyFileManager sharedManager];
    
    NSString *dirPath = [myFileManager currentFullDirectoryPath];
    NSString *fileFullPath = [dirPath stringByAppendingPathComponent: fileArray[i]];
    
    // Perform segue
    [self performSegueWithIdentifier:@"ImageViewSegue"
                              sender:[UIImage imageWithContentsOfFile:fileFullPath]];
}


//-------------
// Deleting rows
//-------------
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //https://developer.apple.com/library/ios/documentation/userexperience/conceptual/tableview_iphone/ManageInsertDeleteRow/ManageInsertDeleteRow.html
    
    int section_id = [indexPath section];
    //-----------------------
    // Delete a snapshot file
    //-----------------------
    int i = [indexPath row];
    
    MyFileManager *myFileManager = [MyFileManager sharedManager];
    
    NSString *dirPath = [myFileManager currentFullDirectoryPath];
    NSString *fileFullPath = [dirPath stringByAppendingPathComponent: fileArray[i]];
    
    // delete a file
    [myFileManager removeItemAtPath:fileFullPath error:nil];
    
    [self initFileList];
    [self.myTableView reloadData];
}

// Reload the directory
- (IBAction)reloadICloud:(id)sender {
    
    NSError *error = nil;
    NSURL *documentDirectoryURL = [self.rootViewController.myFileManager currentFullDirectoryURL];
    
    [self.rootViewController.myFileManager
     startDownloadingUbiquitousItemAtURL:documentDirectoryURL error:&error] ;
    
    if (error != nil)
    {
        NSLog(@"ERROR Loading %@", documentDirectoryURL) ;
    }
    
    
    NSArray *directoryContent = [self.rootViewController.myFileManager
                                 contentsOfDirectoryAtURL:documentDirectoryURL
                                 includingPropertiesForKeys:[[NSArray alloc] initWithObjects:NSURLNameKey, nil]
                                 options:NSDirectoryEnumerationSkipsHiddenFiles
                                 error:&error];
    
    [self initFileList];
    [self.myTableView reloadData];
}

     
#pragma mark -----Navigation and Exit-----
//------------------
// Prepare for the image view
//------------------

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 if ([segue.identifier isEqualToString:@"ImageViewSegue"])
 {
     ImageViewController *destinationViewController =
     segue.destinationViewController;
     
     // grab the annotation from the sender
     destinationViewController.image = sender;
 }
}
@end
