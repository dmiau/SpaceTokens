//
//  SearchPanelView.m
//  SpaceBar
//
//  Created by dmiau on 9/28/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SearchPanelView.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "CustomMKMapView.h"

#import "EntityDatabase.h"
#import "POI.h"
@import GoogleMaps;
@import GooglePlaces;
#import <GoogleMaps/GoogleMaps.h>

#import "TokenCollectionView.h"

@implementation SearchPanelView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark -- Initialization --
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];

    
    return self;
}

-(id)initWithFrame: (CGRect)frame ViewController:(ViewController*) viewController{
    self = [super initWithFrame:frame];
    if (self){
        
    }
    
    return self;
}

- (void)awakeFromNib{
    //-------------------
    // Set the rootViewController
    //-------------------
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    UINavigationController *myNavigationController =
    app.window.rootViewController;
    self.rootViewController = [myNavigationController.viewControllers objectAtIndex:0];
    
    // set up the color of the view
    [self setBackgroundColor:[UIColor colorWithRed: 0.97 green:0.97 blue:0.97
                                             alpha:1.0]];
    [self initSearchBar];
}

//----------------------
// Add and remove the panel
//----------------------
-(void)addPanel{
    [self.rootViewController.view addSubview:self];
    [self.rootViewController removeRoute];
    
    // Reset the SpaceBar interaction environment
    [self.rootViewController.spaceBar resetInteractiveTokenStructures];
    
    // Show the SpaceToken dock
    ((TokenCollectionView*)[TokenCollectionView sharedManager]).isVisible = YES;
    self.rootViewController.spaceBar.spaceBarMode = TOKENONLY;
    
    // Configure the frame
    // Configure the dimesion of the panel
    float width = self.rootViewController.mapView.frame.size.width;
    float height = self.rootViewController.mapView.frame.size.height;
    
    CGRect frame = CGRectZero;
    frame.size.width = width;
    frame.size.height = self.rootViewController.view.frame.size.height - height;
    
    self.frame = frame;
}

-(void)removePanel{
    // Remove the direction button
    [self.directionButton removeFromSuperview];
}

-(void)viewWillAppear:(BOOL)animated{
    [ViewController sharedManager].isStatusBarHidden = NO;
    
    // Reset the frame (for iPad)
    CGRect appFrame = self.rootViewController.view.frame;
    CGRect panelFrame = CGRectMake(0, 0, appFrame.size.width, 150);
    self.frame = panelFrame;
}

#pragma mark -- button actions --

- (void)initDirectionButton{
    //------------------
    // Add a direction button for testing
    //------------------
    UIButton*  directionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    directionButton.frame = CGRectMake(0, 0, 60, 20);
    [directionButton setTitle:@"Direction" forState:UIControlStateNormal];
    directionButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [directionButton setBackgroundColor:[UIColor grayColor]];
    [directionButton addTarget:self.rootViewController action:@selector(directionButtonAction)
              forControlEvents:UIControlEventTouchDown];
    
    // add drop shadow
    //            self.layer.cornerRadius = 8.0f;
    directionButton.layer.masksToBounds = NO;
    //            self.layer.borderWidth = 1.0f;
    
    directionButton.layer.shadowColor = [UIColor grayColor].CGColor;
    directionButton.layer.shadowOpacity = 0.8;
    directionButton.layer.shadowRadius = 12;
    directionButton.layer.shadowOffset = CGSizeMake(12.0f, 12.0f);
    self.directionButton = directionButton;
}


#pragma mark -- Search Initialization --
-(void)initSearchBar{
    _resultsViewController = [[GMSAutocompleteResultsViewController alloc] init];
    _resultsViewController.delegate = self;
    
    _searchController = [[UISearchController alloc]
                         initWithSearchResultsController:_resultsViewController];
    _searchController.searchResultsUpdater = _resultsViewController;
    
    UIView *subView = _searchPlaceHolder;
    
    [subView addSubview:_searchController.searchBar];
    [_searchController.searchBar sizeToFit];
    
    _searchHandlingBlock = nil;
    
    // When UISearchController presents the results view, present it in
    // this view controller, not one further up the chain.
//    self.rootViewController.definesPresentationContext = YES;
}

//-------------------------------
// Handle the user's selection
//-------------------------------
- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
 didAutocompleteWithPlace:(GMSPlace *)place {
    [self.rootViewController dismissViewControllerAnimated:YES completion:nil];
    
//    // Do something with the selected place.
//    NSLog(@"Place name %@", place.name);
//    NSLog(@"Place address %@", place.formattedAddress);
//    NSLog(@"Place attributions %@", place.attributions.string);
    
    // Add a dropped pin
    POI *aPOI = [[POI alloc] init];
    aPOI.name = place.name;
    aPOI.latLon = place.coordinate;
    aPOI.annotation.pointType = dropped;
    aPOI.isMapAnnotationEnabled = YES;
    
    // Add the restul to entityDB
    [[[EntityDatabase sharedManager] entityArray] addObject:aPOI];
    
    if (!self.searchHandlingBlock){
        //----------------------
        // Show the POI if the handling block is empty
        //----------------------
        
        // Get the map object
        CustomMKMapView *mapView = [CustomMKMapView sharedManager];
        GMSCoordinateBounds *viewport = place.viewport;
        // Calculate a suitable region
        MKMapPoint northEast = MKMapPointForCoordinate(viewport.northEast);
        MKMapPoint southWest = MKMapPointForCoordinate(viewport.southWest);
        
        MKMapRect mapRect = MKMapRectMake(southWest.x, northEast.y, northEast.x - southWest.x, southWest.y - northEast.y);
        
        if (mapRect.size.width > 0 && mapRect.size.height > 0){
            // Shift the map to show the location
            [mapView setVisibleMapRect: mapRect
                           edgePadding: UIEdgeInsetsMake(0, 0, 0, 0) animated:YES];
        }else{
            MKCoordinateRegion region =
            MKCoordinateRegionMake(place.coordinate, MKCoordinateSpanMake(0.01, 0.01));
            [mapView setRegion:region animated:YES];
        }
    }else{
        //----------------------
        // Use the handling block to handle the POI
        //----------------------
        self.searchHandlingBlock(aPOI);
        self.searchHandlingBlock = nil;
    }
}

- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
didFailAutocompleteWithError:(NSError *)error {
    [self.rootViewController dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictionsForResultsController:
(GMSAutocompleteResultsViewController *)resultsController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictionsForResultsController:
(GMSAutocompleteResultsViewController *)resultsController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
