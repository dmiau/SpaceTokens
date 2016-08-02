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
        self.rootViewController = (ViewController*) app.window.rootViewController;
        
        //-------------------
        // File Manager Initlialization
        //-------------------
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        
        NSURL *containerURL =
        [fileManager URLForUbiquityContainerIdentifier:nil];
        
        NSString *documentsDirectory =
        [[containerURL path]
         stringByAppendingPathComponent:@"Documents"];
        
        self.documentDirectory = documentsDirectory;
        
    }
    return self;
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
    UITableViewCell *cell = (UITableViewCell *)[tableView                                                dequeueReusableCellWithIdentifier:@"tableCell"];
    
    if (cell == nil){
        NSLog(@"Something wrong...");
    }
    // Get the row ID
    int section_id = [indexPath section];
    int i = [indexPath row];
    
    // Configure Cell
    cell.textLabel.text = self.rootViewController.poiDatabase.poiArray[i].name;
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

@end
