//
//  FileTableController.m
//  SpaceBar
//
//  Created by Daniel on 8/1/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "FileTableController.h"
#import "AppDelegate.h"

@implementation FileTableController

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
    [self initFileList];
    [self.myTableView reloadData];
}

- (void) initFileList{
    // List all the files in the document direction
    fileArray = [[NSFileManager defaultManager]
                 contentsOfDirectoryAtPath:self.documentDirectory error:NULL];
    
    //    NSMutableArray *poiFiles = [[NSMutableArray alloc] init];
    //    [dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    //        NSString *filename = (NSString *)obj;
    //        NSString *extension = [[filename pathExtension] lowercaseString];
    //        if ([extension isEqualToString:@"data"]) {
    //            [poiFiles addObject:filename];
    //            NSLog(@"%@", filename);
    //        }
    //    }];
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

// Reload the directory
- (IBAction)reloadICloud:(id)sender {
    
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];

    
    NSURL *containerURL =
    [fileManager URLForUbiquityContainerIdentifier:nil];
    
    NSURL *documentDirectoryURL = [containerURL URLByAppendingPathComponent:@"Documents"];
    
    [fileManager startDownloadingUbiquitousItemAtURL:documentDirectoryURL error:&error] ;
    
    if (error != nil)
    {
        NSLog(@"ERROR Loading %@", documentDirectoryURL) ;
    }

    
    NSArray *directoryContent = [[NSFileManager defaultManager]
            contentsOfDirectoryAtURL:documentDirectoryURL
            includingPropertiesForKeys:[[NSArray alloc] initWithObjects:NSURLNameKey, nil]
                                 options:NSDirectoryEnumerationSkipsHiddenFiles
                                 error:&error];
    
    [self initFileList];
    [self.myTableView reloadData];
}
@end
