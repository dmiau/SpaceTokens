//
//  StreetViewPanel.h
//  SpaceBar
//
//  Created by dmiau on 8/14/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "topPanel.h"
#import "../StudyManager/GameManager.h"
#import <GoogleMaps/GoogleMaps.h>

@class ViewController;

@interface StreetViewPanel : UIView <TopPanel, GMSPanoramaViewDelegate>

@property ViewController *rootViewController;
@property GMSPanoramaView *panoView;

@end
