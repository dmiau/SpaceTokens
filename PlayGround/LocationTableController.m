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
#import "CustomMKMapView+Annotations.h"
#import "HighlightedEntities.h"
#import "Person.h"

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

        // Collapse the collection by default
        expandCollectionSection = false;
        
        entityDatabase = [EntityDatabase sharedManager];
        
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

    [self.navigationController setNavigationBarHidden:NO];
    [self.myTableView reloadData];
}

- (void)updateEntityFileList{
    // List all the files in the document direction
    NSArray *fileArray = [[NSFileManager defaultManager]
                          contentsOfDirectoryAtPath:
                          [self.rootViewController.myFileManager currentFullDirectoryPath] error:NULL];
    
    // List all the files with the .snapshot extention
    entityFileArray = [fileArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self CONTAINS '.entitydb'"]];
}


#pragma mark -----Table View Data Source Methods-----
typedef enum {COLLECTIONS, ENTITIES, PERSON} sectionEnum;


//----------------
// Prepare the section
//----------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section ==COLLECTIONS){
        if (expandCollectionSection)
            return [entityFileArray count];
        else
            return 0;
    }else if (section ==ENTITIES){
        
        return [[[EntityDatabase sharedManager] getEntityArray] count];
    }else{
        // Person
        return 1;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    NSArray *list;
    
    if (entityDatabase.currentFileName){
        list = @[@"EntityDB files", entityDatabase.currentFileName, @"Person"];
    }else{
        list = @[@"EntityDB files", @"No file found", @"Person"];
    }
    
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
        [self updateEntityFileList];
        expandCollectionSection = !expandCollectionSection;
        [self.myTableView reloadData];
    }
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
    
    
    if (section_id == COLLECTIONS){
        [cell.mySwitch setHidden:YES];
        cell.textLabel.text = entityFileArray[i];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", i];
        
    }else if (section_id == ENTITIES){
        [cell.mySwitch setHidden:NO];
        // Configure Cell
        SpatialEntity *entity = [[EntityDatabase sharedManager] getEntityArray][i];
        cell.textLabel.text = entity.name;
        cell.spatialEntity = entity;
        
        cell.mySwitch.on = cell.spatialEntity.isEnabled;
    }else{
        [cell.mySwitch setHidden:NO];
        // Configure Cell
        Person *person = [EntityDatabase sharedManager].youRHere;
        cell.textLabel.text = person.name;
        cell.spatialEntity = person;
        
        cell.mySwitch.on = cell.spatialEntity.isEnabled;
    }
    return cell;
}

#pragma mark -----Table Interaction Methods-----
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)path {
    
    int row_id = [path row];
    int section_id = [path section];
    
    if (section_id == COLLECTIONS){
        //----------------
        // User selects a file
        //----------------
        MyFileManager *myFileManager = [MyFileManager sharedManager];
        
        NSString *dirPath = [myFileManager currentFullDirectoryPath];
        NSString *fileFullPath = [dirPath stringByAppendingPathComponent:entityFileArray[row_id]];
        [entityDatabase loadFromFile:fileFullPath];
        expandCollectionSection = false;
        [self.myTableView reloadData];
        
    }else if (section_id == ENTITIES){
        // Get the selected entity
        SpatialEntity *entity = [[EntityDatabase sharedManager] getEntityArray][row_id];
        
        CustomMKMapView *mapView = [CustomMKMapView sharedManager];
        
        [[CustomMKMapView sharedManager] snapOneCoordinate:entity.latLon
                toXY:CGPointMake(mapView.frame.size.width/2, mapView.frame.size.height/2)
                                                  animated:NO];
        [[HighlightedEntities sharedManager] addEntity:entity];
        
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
    
    if (section_id ==ENTITIES){
        // Perform segue
        [self performSegueWithIdentifier:@"POIDetailVC"
                                  sender:[[EntityDatabase sharedManager] getEntityArray][i]];
    }
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
    // Get the row ID
    int i = [indexPath row];
    int section_id = [indexPath section];
    
    if (section_id ==ENTITIES){
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    // Get the object
    NSMutableArray <SpatialEntity*> *entityArray = [[EntityDatabase sharedManager] getEntityArray];
    
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
    
    int section_id = [indexPath section];
    if (section_id == COLLECTIONS){
        //-----------------------
        // Delete a snapshot file
        //-----------------------
        
        int i = [indexPath row];
        if ([entityFileArray[i] isEqualToString:@"default.entitydb"])
            return;
        
        MyFileManager *myFileManager = [MyFileManager sharedManager];
        
        NSString *dirPath = [myFileManager currentFullDirectoryPath];
        NSString *fileFullPath = [dirPath stringByAppendingPathComponent: entityFileArray[i]];
        
        // delete a file
        [myFileManager removeItemAtPath:fileFullPath error:nil];
        
        [self updateEntityFileList];
        [self.myTableView reloadData];
    }else if (section_id == ENTITIES){
        // If row is deleted, remove it from the list.
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            int i = [indexPath row];
            
            // Remove the annotation
            [[EntityDatabase sharedManager] getEntityArray][i].isMapAnnotationEnabled = NO;
            
            // Remove the Entity
            [[EntityDatabase sharedManager] removeEntity:
             [[EntityDatabase sharedManager] getEntityArray][i]];
            
            // Then, delete the row
            [self.myTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                    withRowAnimation:UITableViewRowAnimationFade];
        }
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

- (IBAction)saveAction:(id)sender {
    [self saveWithFilename:[[EntityDatabase sharedManager] currentFileName]];
}

- (IBAction)reloadAction:(id)sender {
    MyFileManager *myFileManager = [MyFileManager sharedManager];
    
    NSString *dirPath = [myFileManager currentFullDirectoryPath];
    NSString *fileFullPath = [dirPath stringByAppendingPathComponent:entityDatabase.currentFileName];
    
    [self.rootViewController.entityDatabase loadFromFile:fileFullPath];

    // Reload the table
    [self.myTableView reloadData];
}

- (IBAction)saveAsAction:(id)sender {
    // Prompt a dialog box to get the filename
    UIAlertView *alertView =
    [[UIAlertView alloc] initWithTitle:@"File Name"
                               message:@"Please enter a filename"
                              delegate:self
                     cancelButtonTitle:@"Cancel"
                     otherButtonTitles:@"OK", nil];
    
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    [alertView show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:@"OK"]){
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSString *filename = textField.text;
        
        if ([filename rangeOfString:@".entitydb"].location == NSNotFound) {
            filename = [filename stringByAppendingString:@".entitydb"];
        }
        [self saveWithFilename:filename];
        
        // Need to update the section header too
        [self.myTableView reloadData];
    }
}

- (IBAction)newFileAction:(id)sender {
    // Create a new array
    [[EntityDatabase sharedManager] setEntityArray:[NSMutableArray array]];
    [self.myTableView reloadData];
    [self saveWithFilename:@"new.entitydb"];
}

-(void)saveWithFilename:(NSString*)fileName{
    
    if (!fileName){
        fileName = [[EntityDatabase sharedManager] currentFileName];
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        MyFileManager *myFileManager = [MyFileManager sharedManager];
        
        NSString *dirPath = [myFileManager currentFullDirectoryPath];
        NSString *fileFullPath = [dirPath stringByAppendingPathComponent:fileName];
        
        // Test file saving capability
        [self.rootViewController.entityDatabase saveDatatoFileWithName:fileFullPath];
    });
}

@end
