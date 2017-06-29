//
//  ViewController+Debug.m
//  SpaceBar
//
//  Created by dmiau on 6/26/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "ViewController+Debug.h"
#import <QuartzCore/QuartzCore.h>
#import "MyFileManager.h"

@implementation ViewController (Debug)

// Initilize debug UI
- (void)initDebugUI{
    // Add a screen capture button on the map
    self.screenCaptureButton = [[UIButton alloc] init];
    UIButton *screenCaptureButton = self.screenCaptureButton;
    
    // https://stackoverflow.com/questions/8733104/objective-c-property-instance-variable-in-category#
    screenCaptureButton.frame = CGRectMake(255, 400, 90, 60);
    
    [screenCaptureButton addTarget: self
              action: @selector(capturedButtonClicked:)
    forControlEvents: UIControlEventTouchUpInside];
    
    
    [[CustomMKMapView sharedManager] addSubview:screenCaptureButton];
    
    // Customize the style of the button
    screenCaptureButton.backgroundColor = [UIColor grayColor];

    [screenCaptureButton setTitle:@"Capture" forState:UIControlStateNormal];
    
    [screenCaptureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [screenCaptureButton setTitleColor:[UIColor redColor] forState:
     UIControlStateHighlighted];
    
    [screenCaptureButton.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    
    [screenCaptureButton setHidden:YES];
}


// Capture a screenshot
- (void)capturedButtonClicked:(UIButton*) button{
    
    // Hide the button
    [button setHidden: YES];
    
    // https://stackoverflow.com/questions/2200736/how-to-take-a-screenshot-programmatically
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    } else {
        UIGraphicsBeginImageContext([[self view] window].bounds.size);
    }
    
    [[[self view] window].layer renderInContext:UIGraphicsGetCurrentContext()];
    
    
    
    MyFileManager *myFileManager = [MyFileManager sharedManager];
    NSString *dirPath = [myFileManager currentFullDirectoryPath];
    
    
    // Generate a unique file name
    NSDateFormatter *formatter;
    NSString        *dateString;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    
    dateString = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"screenshot-%@.png", dateString];
    

    NSString *fileFullPath = [dirPath stringByAppendingPathComponent:fileName];
    
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = UIImagePNGRepresentation(image);
    if (imageData) {
        
        [imageData writeToFile:fileFullPath atomically:YES];
        
    } else {
        NSLog(@"error while taking screenshot");
    }

    // Unhide the button after the screenshot is taken
    [button setHidden: NO];
    
}


// This contains the debug code.
- (void)runDebuggingCode{
 
    
//    // Display the basic information of a route to a user
//    [[CustomMKMapView sharedManager] showInformationView:@"Happy Birthday!"];
    
}

@end
