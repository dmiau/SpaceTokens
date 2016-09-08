//
//  ViewController.h
//  PlayGround
//
//  Created by dmiau on 1/28/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SpaceBar/SpaceBar.h"
#import "Map/CustomMKMapView.h"
#import "Map/MiniMapView.h"
#import "Map/POIDatabase.h"
#import "MainViewManager.h"
#import "MyFileManager.h"
#import <GoogleMaps/GoogleMaps.h>

@class Route;
@class RouteDatabase;
@class GameManager;

@interface ViewController : UIViewController
<SpaceBarDelegate, MKMapViewDelegate, CustomMKMapViewDelegate>

@property MainViewManager *mainViewManager;
@property MyFileManager *myFileManager;
@property CustomMKMapView *mapView;
@property MiniMapView *miniMapView;
@property SpaceBar *spaceBar;
@property GMSPanoramaView *panoView; //cache a pointer to the StreetView object

// Databases
@property POIDatabase *poiDatabase;
@property GameManager *gameManager;

// Route related methods
@property RouteDatabase *routeDatabase;
@property Route* activeRoute;
- (void)showRouteFromDatabaseWithName:(NSString*) name
                       zoomToOverview: (BOOL) overviewFlag;
- (void)showRoute:(Route*) aRoute zoomToOverview: (BOOL) overviewFlag;
- (void)removeRoute;


// SpaceToken related methods
- (void)refreshSpaceTokens;

// UI Panels
- (void) directionButtonAction;
@end

