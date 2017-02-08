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
#import "MapInformationSheet.h"

#import "EntityDatabase.h"
#import "POI.h"
@import GoogleMaps;
@import GooglePlaces;
#import <GoogleMaps/GoogleMaps.h>

#import "TokenCollectionView.h"
#import "SearchPanelView+Actions.h"
#import "CustomSearchResultViewController.h"

//-------------------
// Parameters
//-------------------
#define topPanelHeight 120
#define bottomPanalHeight 40

@interface SearchPanelView () <CustomSearchResultViewControllerDelegate>

@end

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
    
    [self initSearchBar];
    
    [self initDrawingButton];
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
    
    self.frame = self.rootViewController.view.frame;
    
    // Adjust the frame of MapView
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    CGRect mapFrame = CGRectMake(0, topPanelHeight,
                                 self.frame.size.width,
                                 self.frame.size.height - topPanelHeight - bottomPanalHeight);
    mapView.frame = mapFrame;
    
    // Refresh the position of the tokens
    [TokenCollectionView sharedManager].isVisible = YES;
}

-(void)removePanel{
    [self removeFromSuperview];
    // Remove the direction button
    [self.directionButton removeFromSuperview];
}

-(void)viewWillAppear:(BOOL)animated{
    [ViewController sharedManager].isStatusBarHidden = NO;
    [self.rootViewController updateUIPlacement];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {    
        
    // UIView will be "transparent" for touch events if we return NO
    return (point.y < topPanelHeight || point.y > self.frame.size.height - bottomPanalHeight);
}

#pragma mark -- Search Initialization --
-(void)initSearchBar{
    _resultsViewController = [[CustomSearchResultViewController alloc] init];
    _resultsViewController.delegate = self;
    
    
    _searchController = [[UISearchController alloc]
                         initWithSearchResultsController:_resultsViewController];
    _searchController.searchResultsUpdater = _resultsViewController;
    
    UIView *subView = _searchPlaceHolder;
    
    [subView addSubview:_searchController.searchBar];
    [_searchController.searchBar sizeToFit];
    
    _searchController.searchBar.delegate = self;
    
    _searchHandlingBlock = nil;
    
    // When UISearchController presents the results view, present it in
    // this view controller, not one further up the chain.
//    self.rootViewController.definesPresentationContext = YES;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    // Specify the search bias to the current visible map area
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    
    CLLocationCoordinate2D northeast =
    mapView.projection.visibleRegion.farRight;
    
    CLLocationCoordinate2D southwest =
    mapView.projection.visibleRegion.nearLeft;
    
    _resultsViewController.autocompleteBounds =
    [[GMSCoordinateBounds alloc]
     initWithCoordinate: northeast coordinate: southwest];
    
    return YES;
}

// MARK: Search result delegate
- (void)didAutocompleteWithPlaces:(NSArray<GMSPlace *> *)places{
    
    GMSCoordinateBounds *bound = [places firstObject].viewport;
    NSMutableArray *poiArray = [NSMutableArray array];
    for (GMSPlace *place in places){
        // Add the search result to the map
        POI *aPOI = [[POI alloc] init];
        aPOI.name = place.name;
        aPOI.latLon = place.coordinate;
        aPOI.placeID = place.placeID;
        aPOI.annotation.pointType = DEFAULT_MARKER;
        
        aPOI.annotation.isHighlighted = YES;
        aPOI.isMapAnnotationEnabled = YES;
        [poiArray addObject:aPOI];
        // registered the highlighted entity
        [EntityDatabase sharedManager].lastHighlightedEntity = aPOI;
        [[[CustomMKMapView sharedManager] informationSheet] addSheetForEntity:aPOI];
        
        bound = [bound includingBounds:place.viewport];
    }

    if (!self.searchHandlingBlock){
        //----------------------
        // Show the POI if the handling block is empty
        //----------------------
        
        // Get the map object
        CustomMKMapView *mapView = [CustomMKMapView sharedManager];
        
        GMSCameraUpdate *newCamera = [GMSCameraUpdate fitBounds: bound
                                                 withEdgeInsets:mapView.edgeInsets];
        [mapView moveCamera: newCamera];
    }else{
        //----------------------
        // Use the handling block to handle the POI
        //----------------------
        
        self.searchHandlingBlock([poiArray firstObject]);
        self.searchHandlingBlock = nil;
    }
    
    [self.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
 didAutocompleteWithPlace:(GMSPlace *)place {
    
    [self.rootViewController dismissViewControllerAnimated:YES completion:nil];
    
    
    // Add the search result to the map
    POI *aPOI = [[POI alloc] init];
    aPOI.name = place.name;
    aPOI.latLon = place.coordinate;
    aPOI.placeID = place.placeID;
    aPOI.annotation.pointType = DEFAULT_MARKER;
    aPOI.annotation.isHighlighted = YES;
    aPOI.isMapAnnotationEnabled = YES;
    
    // registered the highlighted entity
    [EntityDatabase sharedManager].lastHighlightedEntity = aPOI;
    [[[CustomMKMapView sharedManager] informationSheet] addSheetForEntity:aPOI];
    
    if (!self.searchHandlingBlock){
        //----------------------
        // Show the POI if the handling block is empty
        //----------------------
        
        // Get the map object
        CustomMKMapView *mapView = [CustomMKMapView sharedManager];
        GMSCameraUpdate *newCamera = [GMSCameraUpdate fitBounds: place.viewport
                                      withEdgeInsets:mapView.edgeInsets];
        
        [mapView moveCamera: newCamera];
        [mapView updateCenterCoordinates:place.coordinate];

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
