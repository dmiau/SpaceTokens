//
//  SpaceBar+Interactions.m
//  SpaceBar
//
//  Created by Daniel on 6/30/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SpaceBar+Interactions.h"
#import "POIDatabase.h"

@implementation SpaceBar (Interactions)

//-----------------------
// delegate methods of CERangeSliderDelegate
- (void) privateSliderOnePointTouched: (double) percentage{
    
    if (self.delegateRespondsTo.spaceBarOnePointTouched){
        // need to take the current upper and lower value into accunt
        if (!self.smallValueOnTopOfBar){
            // when the small value is on the bottom
            percentage = 1 - percentage;
        }
        [self.delegate spaceBarOnePointTouched: percentage];
    }
}

- (void) privateSliderTwoPOintsTouchedLow:(double)lowerPercentage high:(double)upperPercentage
{
    if (self.delegateRespondsTo.spaceBarTwoPointsTouched){
        
        if (!self.smallValueOnTopOfBar){
            double templowerPercentage = lowerPercentage;
            lowerPercentage = 1 - upperPercentage;
            upperPercentage = 1 - templowerPercentage;
        }        
        [self.delegate spaceBarTwoPointsTouchedLow:lowerPercentage high:upperPercentage];
    }
}

- (void) privateSliderElevatorMovedLow:(double) lowerPercentage
                                  high:(double)upperPercentage
                                  fromLowToHigh: (bool) directionFlag
{
    if (self.delegateRespondsTo.spaceBarElevatorMoved){
        
        if (!self.smallValueOnTopOfBar){
            double templowerPercentage = lowerPercentage;
            lowerPercentage = 1 - upperPercentage;
            upperPercentage = 1 - templowerPercentage;
            directionFlag = !directionFlag;
        }
        [self.delegate spaceBarElevatorMovedLow:lowerPercentage
                                           high:upperPercentage
                                  fromLowToHigh: directionFlag];
    }
}
//-----------------------

- (void) updateElevatorFromPercentagePair: (float[2]) percentagePair{
    
    float low, high;
    if (isnan(percentagePair[0]) || isnan(percentagePair[1])){
        low = nanf(""); high = nanf("");
    }else{
        low = MIN(percentagePair[0], percentagePair[1]);
        high = MAX(percentagePair[0], percentagePair[1]);
        
        if (!self.smallValueOnTopOfBar){
            double tempLow = low;
            low = 1 - high;
            high = 1 -tempLow;
        }
    }

    [self.sliderContainer updateElevatorPercentageLow:low high:high];
}

- (void) addAnchorForTouches:(NSSet<UITouch *> *)touches{

    static int counter = 0;
    
    // Note: there could be more than one touch point
    // For now, let's only handle the case when there is only one touch point
    if ([touches count] == 1){
        UITouch *touch = [touches anyObject];
        CGPoint mapXY = [touch locationInView:self.mapView];
        CLLocationCoordinate2D coord = [self.mapView convertPoint:mapXY
                                             toCoordinateFromView:self.mapView];
        if (!self.anchor){
            // create a new POI for anchor if an anchor does not exist
            SpaceToken *aToken = [[SpaceToken alloc] init];
            [aToken configureAppearanceForType:ANCHORTOKEN];
            
            // Add the anchor to the map
            [self.mapView addSubview:aToken];
            
            // Position the SpaceToken correctly
            aToken.center = mapXY;
            aToken.poi.latLon = coord;
            aToken.mapViewXY = mapXY;
            aToken.poi.name = [NSString stringWithFormat:@"Anchor%d", counter++];
            
            self.anchor = aToken;
        }
    }
}

- (void) updateAnchorForTouches:(NSSet<UITouch *> *)touches
{
    if ([touches count] == 1){
        if (self.anchor){
            UITouch *touch = [touches anyObject];
            CGPoint mapXY = [touch locationInView:self.mapView];
            
            // Create a SpaceToken if the touch falls into the creation zone
            if (mapXY.x > 0.95 * self.mapView.frame.size.width){
                [self convertAnchorToRealToken:self.anchor];
            }else{
                // Position the SpaceToken correctly
                self.anchor.center = mapXY;
                self.anchor.mapViewXY = mapXY;
            }
        }
    }
}

- (void) removeAnchor{
    // remove the anchor from the dragging set
    if (self.anchor){
        [self.draggingSet removeObject:self.anchor];
        [self.anchor removeFromSuperview];
        self.anchor = nil;
    }
}

- (void) convertAnchorToRealToken: (SpaceToken*) token{    
    // Create a new SpaceToken based on anchor
    SpaceToken* newSpaceToken =
    [self addSpaceTokenFromPOI:token.poi];
    [self removeAnchor];
    [self orderButtonArray];
    
    [self.poiArrayDataSource addObject:token.poi];
}

@end
