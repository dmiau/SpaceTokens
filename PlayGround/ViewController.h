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

@class Route;

@interface ViewController : UIViewController <SpaceBarDelegate>

@property UIButton *myButton;
@property MKMapView *mapView;

@property SpaceBar *spaceBar;
@property Route *route;
@end

