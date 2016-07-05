//
//  customMKMapView.h
//  SpaceBar
//
//  Created by Daniel on 7/4/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <MapKit/MapKit.h>

//@protocol customMKMapViewDelegate <NSObject>
//
//- (void) mapWasUpdated;
//@end


@interface customMKMapView : MKMapView

@property (nonatomic, weak) id<MKMapViewDelegate> delegate;
@end
