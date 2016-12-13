//
//  SearchPanelView+Actions.m
//  SpaceBar
//
//  Created by dmiau on 12/12/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SearchPanelView+Actions.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "SpeechEngine.h"

@implementation SearchPanelView (Actions)

- (void)directionButtonAction {
    NSLog(@"Direction button pressed!");
    
    //    // Check if a route has been loaded
    //
    //
    //    // Get the direction from New York to Boston
    //    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    //
    //
    //    // Start map item (New York)
    //    MKPlacemark *startPlacemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(40.712784, -74.005941) addressDictionary:nil];
    //    MKMapItem *startMapItem = [[MKMapItem alloc] initWithPlacemark:startPlacemark];
    //    [startMapItem setName:@"New York"];
    //    request.source = startMapItem;
    //
    //    // End map item (Boston)
    //    MKPlacemark *endPlacemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(42.360082, -71.058880) addressDictionary:nil];
    //    MKMapItem *endMapItem = [[MKMapItem alloc] initWithPlacemark:endPlacemark];
    //    [endMapItem setName:@"Boston"];
    //    request.destination = endMapItem;
    //
    //
    //    request.requestsAlternateRoutes = YES;
    //    MKDirections *directions =
    //    [[MKDirections alloc] initWithRequest:request];
    //
    //    [directions calculateDirectionsWithCompletionHandler:
    //     ^(MKDirectionsResponse *response, NSError *error) {
    //         if (error) {
    //             // Handle Error
    //         } else {
    //             NSLog(@"Direction response received!");
    //             MKRoute *tempRoute = response.routes[0];
    //             Route *myRoute =
    //             [[Route alloc] initWithMKRoute:tempRoute
    //                                     Source:response.source Destination:response.destination];
    //             [self showRoute:myRoute zoomToOverview: YES];
    //         }
    //         //         [self updateSpaceBar];
    //     }];
    
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    UINavigationController *myNavigationController =
    app.window.rootViewController;
    
    ViewController *rootViewController = [myNavigationController.viewControllers objectAtIndex:0];
    
    // Add the direction panel
    [rootViewController.mainViewManager showPanelWithType:DIRECTION];
}


- (void)dataButtonAction{
    //-------------------
    // Set the rootViewController
    //-------------------
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    UINavigationController *myNavigationController =
    app.window.rootViewController;
    
    ViewController *rootViewController = [myNavigationController.viewControllers objectAtIndex:0];
    
    [rootViewController performSegueWithIdentifier:@"DataSegue"
                                            sender:nil];
}


- (IBAction)prefAction:(id)sender {
    //-------------------
    // Set the rootViewController
    //-------------------
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    UINavigationController *myNavigationController =
    app.window.rootViewController;
    
    //    ViewController *rootViewController =
    //    [myNavigationController.viewControllers objectAtIndex:0];
    //
    //    [rootViewController performSegueWithIdentifier:@"PreferencesSegue"
    //                                            sender:nil];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *destinationController = (UIViewController *)[sb instantiateViewControllerWithIdentifier:@"PreferenceTabController"];
    CATransition* transition = [CATransition animation];
    transition.duration = .25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    
    [myNavigationController.view.layer addAnimation:transition
                                             forKey:kCATransition];
    
    [myNavigationController pushViewController:destinationController animated:NO];
}

- (IBAction)barToolAction:(id)sender {
    SpaceBar *spaceBar = [SpaceBar sharedManager];
    spaceBar.isBarToolHidden = !spaceBar.isBarToolHidden;
}

- (IBAction)dataAction:(id)sender {
    //-------------------
    // Set the rootViewController
    //-------------------
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    UINavigationController *myNavigationController =
    app.window.rootViewController;
    
    ViewController *rootViewController = [myNavigationController.viewControllers objectAtIndex:0];
    
    [rootViewController performSegueWithIdentifier:@"DataSegue"
                                            sender:nil];
}

// MARK: -- Speech button action
- (IBAction)speechAction:(id)sender {
    [self.rootViewController.speechEngine showDebugLayer];
}

@end
