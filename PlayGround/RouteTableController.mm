//
//  RouteTableController.m
//  SpaceBar
//
//  Created by Daniel on 8/5/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "RouteTableController.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "Map/RouteDatabase.h"

@implementation RouteTableController{
    RouteDatabase *routeDatabase;
    NSMutableArray *keyArray;
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
        routeDatabase = self.rootViewController.routeDatabase;
        keyArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)awakeFromNib{
    
}

- (void)viewWillAppear:(BOOL)animated{
    [keyArray removeAllObjects]; // reset the array
    keyArray = [routeDatabase.routeDictionary allKeys];
    [self.myTableView reloadData];
}

#pragma mark -----Table View Data Source Methods-----
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Three sections: user location, the location file listing, and bookmarks
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [keyArray count];
}

//----------------
// Populate each row of the table
//----------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView                                                dequeueReusableCellWithIdentifier:@"routeCell"];
    
    if (cell == nil){
        NSLog(@"Something wrong...");
    }
    // Get the row ID
    int section_id = [indexPath section];
    int i = [indexPath row];
    
    // Configure Cell
    cell.textLabel.text = keyArray[i];
    return cell;
}


#pragma mark -----Table Interaction Methods-----
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)path {
    
    int row_id = [path row];
    int section_id = [path section];
    
    [self.rootViewController showRoute:routeDatabase.routeDictionary[keyArray[row_id]]
                        zoomToOverview:YES];
    //--------------
    // We might need to do something for iPad
    //--------------
    [self.navigationController popViewControllerAnimated:NO];
}


- (IBAction)saveAction:(id)sender {
//    //Save the files using the background thread
//    //http://stackoverflow.com/questions/12671042/moving-a-function-to-a-background-thread-in-objective-c
//    
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
//    dispatch_async(queue, ^{
//        NSString *dirPath = [self.rootViewController.myFileManager currentFullDirectoryPath];
//        NSString *fileFullPath = [dirPath stringByAppendingPathComponent:@"myTest.route"];
//        
//        // Test file saving capability
//        [routeDatabase saveDatatoFileWithName:fileFullPath];
//                
//        // Perform async operation
//        // Call your method/function here
//        // Example:
//        // NSString *result = [anObject calculateSomething];
//    });
    
    
}

- (IBAction)reloadAction:(id)sender {
//    [routeDatabase loadFromFile:fileFullPath];
}

- (IBAction)clearAction:(id)sender {
}
@end
