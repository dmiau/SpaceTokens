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
#import "Map/customMKMapView.h"
#import "Map/POIDatabase.h"
#import "MainViewManager.h"
#import "MyFileManager.h"

@class Route;
@class RouteDatabase;
@class GameManager;

@interface ViewController : UIViewController
<SpaceBarDelegate, MKMapViewDelegate, customMKMapViewDelegate>

@property MainViewManager *mainViewManager;
@property MyFileManager *myFileManager;
@property customMKMapView *mapView;
@property SpaceBar *spaceBar;


// Databases
@property POIDatabase *poiDatabase;
@property GameManager *gameManager;

// Route related methods
@property RouteDatabase *routeDatabase;
@property Route* activeRoute;
- (void)showRoute:(Route*) aRoute;
- (void)removeRoute;

// UI Panels
- (void) directionButtonAction;
@end

