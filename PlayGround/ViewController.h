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
@class StudyManager;

@interface ViewController : UIViewController
<SpaceBarDelegate, MKMapViewDelegate, customMKMapViewDelegate>

@property MainViewManager *mainViewManager;
@property MyFileManager *myFileManager;
@property UIButton *myButton;
@property customMKMapView *mapView;
@property SpaceBar *spaceBar;


@property POIDatabase *poiDatabase;
@property RouteDatabase *routeDatabase;

@property Route* activeRoute;
@property StudyManager *studyManager;


- (void)showRoute:(Route*) aRoute;


// UI Panels

- (void) addDirectionPanel;
- (void) initSpaceBarWithTokens;
- (void)directionButtonAction;
@end

