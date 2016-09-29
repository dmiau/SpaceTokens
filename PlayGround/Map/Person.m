//
//  Person.m
//  SpaceBar
//
//  Created by dmiau on 8/23/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "Person.h"
#import "CustomMKMapView.h"

@implementation Person{
    CLLocationManager *locationManager;
}

- (id)init{
    self = [super init];
    if (self){
        _updateFlag = NO;
        _poi = [[POI alloc] init];
        _poi.name = @"YouRHere";
        _poi.annotation.pointType = YouRHere;
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return self;
}

-(void)setUpdateFlag:(BOOL)updateFlag{
    _updateFlag = updateFlag;
    // Get the map object
    CustomMKMapView *myMapView = [CustomMKMapView sharedManager];
    
    if (_updateFlag){
        // Turn on the location flag
        // for iOS 8, specific user level permission is required,
        // "when-in-use" authorization grants access to the user's location
        //
        // important: be sure to include NSLocationWhenInUseUsageDescription along with its
        // explanation string in your Info.plist or startUpdatingLocation will not work.
        //
        if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        {
            [locationManager requestWhenInUseAuthorization];
        }
        
        [locationManager startUpdatingLocation];
        [locationManager startUpdatingHeading];
        self.poi.isMapAnnotationEnabled = YES;
    }else{
        // Stop Location Manager
        [locationManager stopUpdatingLocation];
        [locationManager stopUpdatingHeading];
        self.poi.isMapAnnotationEnabled = NO;
    }
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
    //    self.findMeButton.backgroundColor = [UIColor clearColor];
}

//-------------------
// Locaiton is updated
//-------------------
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* myLocation = [locations lastObject];
    self.poi.latLon = myLocation.coordinate;
    
    [self updateMapAnnotation];
}

//-------------------
// Heading is updated
//-------------------
- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading
{
    self.poi.headingInDegree = [newHeading trueHeading];
    // heading is in degree
    [self updateMapAnnotation];
}


- (void)updateMapAnnotation{
    // Get the map object
    CustomMKMapView *myMapView = [CustomMKMapView sharedManager];
    
    MKAnnotationView *myAnnotationView = [myMapView viewForAnnotation: self.poi.annotation];
    
    // Update the orientation
    UIImage *myImg = [UIImage imageNamed:@"heading.png"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Your code to run on the main queue/thread
        
        //-------------
        // rotate the image according to the current heading
        //-------------
        [myAnnotationView setImage:myImg];
        [myAnnotationView setNeedsDisplay];
        
        float radians = (self.poi.headingInDegree)/180 * M_PI;
        
        //        NSLog(@"camera orientation: %f", self.model->camera_pos.orientation);
        //        NSLog(@"User orientation: %f", self.model->user_pos.orientation);
        
        CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, radians);
        myAnnotationView.transform = transform;
    });
}

@end
