//
//  ViewController.h
//  PlayGround
//
//  Created by dmiau on 1/28/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "NavTools.h"
#import "Map/CustomMKMapView.h"
#import "Map/MiniMapView.h"
#import "MainViewManager.h"
#import "MyFileManager.h"
#import <GoogleMaps/GoogleMaps.h>

@class Route;
@class GameManager;
@class EntityDatabase;
@class SpeechEngine;

@interface ViewController : UIViewController
<PathBarDelegate, GMSMapViewDelegate, CustomMKMapViewDelegate>

@property MainViewManager *mainViewManager;
@property MyFileManager *myFileManager;
@property CustomMKMapView *mapView;
@property MiniMapView *miniMapView;
@property NavTools *navTools;
@property GMSPanoramaView *panoView; //cache a pointer to the StreetView object
@property BOOL isStatusBarHidden;

// MARK: Constraint Engine
@property SpeechEngine *speechEngine;

// Databases
@property EntityDatabase *entityDatabase;
@property GameManager *gameManager;


// Common access method
+ (ViewController*)sharedManager;

// Update the placement of UI elements (e.g., TokenCollectionView, ArrayTool, etc.)
- (void)updateUIPlacement;

// Route related methods
- (void)showRoute:(Route*) aRoute zoomToOverview: (BOOL) overviewFlag;
- (void)removeRoute;


// Debug
- (void)runDebuggingCode;
@property UIButton *screenCaptureButton; // This is the screen capture button above the map

@end

