//
//  LocationTableController.m
//  SpaceBar
//
//  Created by Daniel on 7/18/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "LocationTableController.h"
#import "ViewController.h"
#import "AppDelegate.h"
#import "POIDetailViewController.h"
#import "EntityDatabase.h"

#pragma mark --Entity Cell--
//---------------------
// landmarkCell interface
//---------------------
@interface landmarkCell :UITableViewCell

@property UISwitch* mySwitch;
@property ViewController* rootViewController;
@property SpatialEntity* spatialEntity;
@property bool isUserLocation;

@end

//---------------------
// landmarkCell implementation
//---------------------
@implementation landmarkCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
    {
        //-------------------
        // Create an UISwitch
        //-------------------
        UISwitch *onoff = [[UISwitch alloc]
                           initWithFrame:CGRectMake(260, 6, 51, 31)];
        [onoff addTarget: self action: @selector(flipSingleLandmark:) forControlEvents:UIControlEventValueChanged];
        onoff.on = false;
        self.mySwitch = onoff;
        [self addSubview:onoff];
        
        //-------------------
        // Set the rootViewController
        //-------------------
        AppDelegate *app = [[UIApplication sharedApplication] delegate];
        
        UINavigationController *myNavigationController =
        app.window.rootViewController;
        
        self.rootViewController =
        [myNavigationController.viewControllers objectAtIndex:0];
        
        [self setAccessoryType: UITableViewCellAccessoryDetailButton];
    }
    return self;
}

- (void) flipSingleLandmark:(UISwitch*)sender{
    if (sender.isOn) {
        self.spatialEntity.isEnabled = true;
    } else {
        self.spatialEntity.isEnabled = false;
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animate{
    
    if (editing){
        [self.mySwitch setHidden:YES];
        [self setEditingAccessoryType: UITableViewCellAccessoryDetailButton];
    }else{
        [self.mySwitch setHidden:NO];
        if (self.spatialEntity)
            self.mySwitch.on = self.spatialEntity.isEnabled;
        [self setEditingAccessoryType: UITableViewCellAccessoryNone];
    }
    [super setEditing:editing animated:animate];
}

@end



#pragma mark --LocationTableController--
@implementation LocationTableController

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    //-----------------
    // Register the custom cell
    //-----------------
    [self.myTableView registerClass:[landmarkCell class]
             forCellReuseIdentifier:@"myTableCell"];
}

- (void)awakeFromNib{
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    // Update SpaceToken order control
    if (self.rootViewController.spaceBar.isAutoOrderSpaceTokenEnabled){
        self.orderSegmentOutlet.selectedSegmentIndex = 0;
    }else{
        self.orderSegmentOutlet.selectedSegmentIndex = 1;
    }
    
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.myTableView reloadData];
}

#pragma mark -----Table View Data Source Methods-----
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Location table has only one section currently
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.rootViewController.entityArraySource count];
}

//----------------
// Populate each row of the table
//----------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    landmarkCell *cell = (landmarkCell *)[tableView                                                dequeueReusableCellWithIdentifier:@"myTableCell"];
    
    if (cell == nil){
        NSLog(@"Something wrong...");
    }
    // Get the row ID
    int section_id = [indexPath section];
    int i = [indexPath row];
    
    // Configure Cell
    cell.textLabel.text = self.rootViewController.entityArraySource[i].name;
    cell.spatialEntity = self.rootViewController.entityArraySource[i];
    
    cell.mySwitch.on = cell.spatialEntity.isEnabled;
    return cell;
}

#pragma mark -----Table Interaction Methods-----
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)path {
    
    int row_id = [path row];
    int section_id = [path section];
    
    [self dismissViewControllerAnimated:YES completion:^{
        // call your completion method:
//        [parentVC viewWillAppear:YES];
    }];
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
    
    // Perform segue
    [self performSegueWithIdentifier:@"POIDetailVC"
                              sender:self.rootViewController.entityArraySource[i]];
}


//----------------
// Reorder the cell
//----------------
- (IBAction)editAction:(id)sender {
    UIButton *button = (UIButton*) sender;
    
    if ([button.titleLabel.text isEqualToString:@"Edit"]){
        [self.myTableView setEditing:YES animated:YES];
        [self.editOutlet setTitle:@"Done" forState:UIControlStateNormal];
    }else{
        [self.myTableView setEditing:NO animated:YES];
        [self.editOutlet setTitle:@"Edit" forState:UIControlStateNormal];
    }
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    // Get the object
    NSMutableArray <SpatialEntity*> *entityArray = self.rootViewController.entityArraySource;
    
    SpatialEntity *anEntity = entityArray[sourceIndexPath.row];
    [entityArray removeObjectAtIndex:sourceIndexPath.row];
    [entityArray insertObject:anEntity atIndex:destinationIndexPath.row];
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

        // Remove the annotation
        self.rootViewController.entityArraySource[i].isMapAnnotationEnabled = NO;
        
        // Remove the Entity
        [self.rootViewController.entityArraySource removeObject:
         self.rootViewController.entityArraySource[i]];
        
        // Then, delete the row
        [self.myTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
    }
}


#pragma mark -----Navigation and Exit-----
//------------------
// Prepare for the detail view
//------------------
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(SpatialEntity*)sender
{
    if ([segue.identifier isEqualToString:@"POIDetailVC"])
    {
        POIDetailViewController *destinationViewController =
        segue.destinationViewController;
        
        // grab the annotation from the sender
        destinationViewController.spatialEntity = sender;
    }
}

#pragma mark --Save/Reload--
- (IBAction)orderSegmentAction:(UISegmentedControl*)sender {
    if (sender.selectedSegmentIndex == 0){
        self.rootViewController.spaceBar.isAutoOrderSpaceTokenEnabled = YES;
    }else{
        self.rootViewController.spaceBar.isAutoOrderSpaceTokenEnabled = NO;
    }
}

- (IBAction)saveAction:(id)sender {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        MyFileManager *myFileManager = [MyFileManager sharedManager];
        
        NSString *dirPath = [myFileManager currentFullDirectoryPath];
        NSString *fileFullPath = [dirPath stringByAppendingPathComponent:@"myTest.data"];
        
        // Test file saving capability
        [self.rootViewController.entityDatabase saveDatatoFileWithName:fileFullPath];
    });
}

- (IBAction)reloadAction:(id)sender {
    MyFileManager *myFileManager = [MyFileManager sharedManager];
    
    NSString *dirPath = [myFileManager currentFullDirectoryPath];
    NSString *fileFullPath = [dirPath stringByAppendingPathComponent:@"myTest.data"];
    
    [self.rootViewController.entityDatabase loadFromFile:fileFullPath];
    // Need to reconnec the data source
    [self.rootViewController.spaceBar
     addSpaceTokensFromEntityArray: self.rootViewController.entityArraySource];
    // Reload the table
    [self.myTableView reloadData];
}


@end
