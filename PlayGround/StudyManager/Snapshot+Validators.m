//
//  Snapshot+Validators.m
//  SpaceBar
//
//  Created by Daniel on 9/11/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "Snapshot+Validators.h"


#import <Foundation/Foundation.h>
#import "SnapshotProtocol.h"
#import "AppDelegate.h"
#import "CustomMKMapView.h"
#import "Constants.h"
#import "Record.h"
#import "GameManager.h"
#import "ViewController.h"

@implementation Snapshot (Validators)

#pragma mark --Validator--

//------------------------
// One point validator
//------------------------
- (void)onePointValidator{
    
    // Stop the timer when the goal is achieved
    BOOL passFlag = NO;
    
    // validator should only be called once
    if (self.record.isAnswered){
        return;
    }
    
    CustomMKMapView *mapView = self.rootViewController.mapView;
    
    
    // Make sure the target circle is visible
    MKMapPoint targetMapPoint = MKMapPointForCoordinate(self.targetedPOIs[0].latLon);
    
    
    MKMapRect mapViewRect =  mapView.visibleMapRect;
    MKMapRect targetRect = [CustomMKMapView MKMapRectForCoordinateRegion:
                            MKCoordinateRegionMake(self.targetedPOIs[0].latLon,
                                                   self.targetedPOIs[0].coordSpan)];
    passFlag = MKMapRectContainsRect(mapViewRect, targetRect);
    
    // Need to check the size of the target area
    // Calculate the screen distance between the two points of the circle
    CLLocationCoordinate2D coord0 =
    CLLocationCoordinate2DMake(self.targetedPOIs[0].latLon.latitude,
                               self.targetedPOIs[0].latLon.longitude -
                               self.targetedPOIs[0].coordSpan.longitudeDelta/2);
    CLLocationCoordinate2D coord1 =
    CLLocationCoordinate2DMake(self.targetedPOIs[0].latLon.latitude,
                               self.targetedPOIs[0].latLon.longitude +
                               self.targetedPOIs[0].coordSpan.longitudeDelta/2);
    CGPoint xy0 = [mapView convertCoordinate:coord0 toPointToView:mapView];
    CGPoint xy1 = [mapView convertCoordinate:coord1 toPointToView:mapView];
    
    double dist = sqrt( pow(xy0.x - xy1.x, 2) + pow(xy0.y - xy1.y, 2)) + 0.1; // to resolve the calculation errors.
    passFlag = passFlag && (dist > self.rootViewController.mapView.frame.size.width * 0.8);
    
//    if (passFlag && !validatorTimer){
//        
//        // Change the color of the circle
//        MKCircleRenderer *renderer =
//        [mapView rendererForOverlay:targetCircle];
//        renderer.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.4];
//        
//        validatorTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
//                                         target:self
//                                       selector:@selector(onePointCompletionAction)
//                                       userInfo:nil
//                                        repeats:NO];        
//    }else if (!passFlag){
//        // Change the color of the circle
//        MKCircleRenderer *renderer =
//        [mapView rendererForOverlay:targetCircle];
//        renderer.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.4];
//
//        [validatorTimer invalidate];
//        validatorTimer = nil;
//    }
}

- (void)onePointCompletionAction{
    [self.record end];
    
    // Disable the map interactions
    self.rootViewController.mapView.userInteractionEnabled = NO;
    
    // Report the result
    GameManager *gameManager = [GameManager sharedManager];
    [gameManager reportCompletionFromSnashot:self];
    
    // Game manager takes care of the following?
    // Clean up
    // Terminate the task
}


#pragma mark --TwoPoints--
//------------------------
// Two point validator
//------------------------
- (void)twoPointsValidator{
    
    // Stop the timer when the goal is achieved
    BOOL passFlag = NO;
    
    // validator should only be called once
    if (self.record.isAnswered){
        return;
    }
    
    CustomMKMapView *mapView = self.rootViewController.mapView;
    
    // Make sure the two points are visible
    CGPoint xy0 = [mapView convertCoordinate:self.targetedPOIs[0].latLon toPointToView:mapView];
    CGPoint xy1 = [mapView convertCoordinate:self.targetedPOIs[1].latLon toPointToView:mapView];
    CGRect mapRect = CGRectMake(0, 0, self.rootViewController.mapView.frame.size.width,
                                self.rootViewController.mapView.frame.size.height);
    passFlag = (CGRectContainsPoint(mapRect, xy0) && CGRectContainsPoint(mapRect, xy1));
    
    // Calculate the screen distance between the two points
    double dist = sqrt( pow(xy0.x - xy1.x, 2) + pow(xy0.y - xy1.y, 2));
    passFlag = passFlag && (dist > self.rootViewController.mapView.frame.size.width);
    
    // if passed, Show the visual indication
    
//    if (passFlag && !validatorTimer){
//        
//        // Change the color of the circle
//        MKCircleRenderer *renderer = (MKCircleRenderer *)
//        [mapView rendererForOverlay:targetCircle];
//        renderer.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.4];
//        
//        validatorTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
//                                                          target:self
//                                                        selector:@selector(twoPointsCompletionAction)
//                                                        userInfo:nil
//                                                         repeats:NO];                
//    }else if (!passFlag){
//        // Change the color of the circle
//        MKCircleRenderer *renderer = (MKCircleRenderer *)
//        [mapView rendererForOverlay:targetCircle];
//        renderer.fillColor = [[UIColor clearColor] colorWithAlphaComponent:0.0];
//        
//        [validatorTimer invalidate];
//        validatorTimer = nil;
//    }
}

- (void)twoPointsCompletionAction{
    [self.record end];

    
    // Disable the map interactions
    self.rootViewController.mapView.userInteractionEnabled = NO;
    
    // Report the result
    GameManager *gameManager = [GameManager sharedManager];
    [gameManager reportCompletionFromSnashot:self];
    
    // Game manager takes care of the following?
    // Clean up
    // Terminate the task
}

#pragma mark --TwoPoints--
//------------------------
// Segment control validator
//------------------------

// This method is called when the user tap the "next" button
- (void)segmentControlValidator{
    [self.record end];
    
    // Check the answer
    self.record.correctSegmentAnswer = self.correctAnswers;
    
    self.record.isCorrect = [self.record.userAnswer isEqualToSet:self.correctAnswers];
    
    // Report the result
    GameManager *gameManager = [GameManager sharedManager];
    [gameManager reportCompletionFromSnashot:self];    
}

@end
