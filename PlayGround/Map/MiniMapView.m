//
//  MiniMapView.m
//  SpaceBar
//
//  Created by Daniel on 8/11/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "MiniMapView.h"

@implementation MiniMapView

- (id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.delegate = self;
        self.syncRotation = NO;
        // Add borders
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 1.0f;
        
    }
    return self;
}


- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id < MKOverlay >)overlay
{
    if ([overlay isKindOfClass:[MKCircle class]]){
        //--------------
        // Circle overlay
        //--------------
        MKCircleRenderer *renderer = [[MKCircleRenderer alloc] initWithOverlay:overlay];
        //        renderer.strokeColor = [UIColor redColor];
        renderer.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.4];
        return renderer;
    }else if (overlay == self.boxPolyline){
        //--------------
        // Minimap box overlay
        //--------------
        MKPolylineRenderer *renderer =
        [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        renderer.strokeColor = [UIColor redColor];
        renderer.lineWidth = 2.0;
        return renderer;
    }else{
        //--------------
        // Route overlay
        //--------------
        MKPolylineRenderer *renderer =
        [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        renderer.strokeColor = [UIColor blueColor];
        renderer.lineWidth = 2.0;
        return renderer;
    }
}

@end
