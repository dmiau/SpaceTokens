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

@class Route;

@interface ViewController : UIViewController
<SpaceBarDelegate, MKMapViewDelegate, customMKMapViewDelegate>

@property UIButton *myButton;
@property customMKMapView *mapView;

@property SpaceBar *spaceBar;
@property Route *route;
@end

