//
//  customMKMapView.h
//  SpaceBar
//
//  Created by Daniel on 7/4/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <MapKit/MapKit.h>

//----------------
// customMKMapViewDelegate
//----------------
@protocol customMKMapViewDelegate <NSObject>

// The following are to support the anchor+x interactions
- (void) mapTouchBegan: (CLLocationCoordinate2D) coord atXY: (CGPoint) xy;
- (void) mapTouchMoved: (CLLocationCoordinate2D) coord atXY: (CGPoint) xy;
- (void) mapTouchEnded;
@end

//----------------
// customMKMapView
//----------------
@interface customMKMapView : MKMapView

@property (nonatomic, weak) id<MKMapViewDelegate, customMKMapViewDelegate> delegate;
@end
