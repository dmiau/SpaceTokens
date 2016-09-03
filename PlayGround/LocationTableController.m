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

#pragma mark --POI Cell--
@interface landmarkCell :UITableViewCell

@property UISwitch* mySwitch;
@property ViewController* rootViewController;
@property POI* poi;
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
        self.poi.isEnabled = true;
    } else {
        self.poi.isEnabled = false;
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animate{
    
    if (editing){
        [self.mySwitch setHidden:YES];
        [self setEditingAccessoryType: UITableViewCellAccessoryDetailButton];
    }else{
        [self.mySwitch setHidden:NO];
        if (self.poi)
            self.mySwitch.on = self.poi.isEnabled;
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
    [self.myTableView reloadData];
}

#pragma mark -----Table View Data Source Methods-----
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Three sections: user location, the location file listing, and bookmarks
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.rootViewController.poiDatabase.poiArray count];
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
    cell.textLabel.text = self.rootViewController.poiDatabase.poiArray[i].name;
    cell.poi = self.rootViewController.poiDatabase.poiArray[i];
    
    cell.mySwitch.on = cell.poi.isEnabled;
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
                              sender:self.rootViewController.poiDatabase.poiArray[i]];
}


#pragma mark -----Navigation and Exit-----
//------------------
// Prepare for the detail view
//------------------
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(CustomPointAnnotation*)sender
{
    if ([segue.identifier isEqualToString:@"POIDetailVC"])
    {
        POIDetailViewController *destinationViewController =
        segue.destinationViewController;
        
        // grab the annotation from the sender
        destinationViewController.poi = sender;
    }
}
@end
