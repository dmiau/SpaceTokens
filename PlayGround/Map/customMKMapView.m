//
//  CustomMKMapView.m
//  NavTools
//
//  Created by Daniel on 7/4/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "CustomMKMapView.h"
#include <stdlib.h>
#import "InformationSheetManager.h"

@implementation CustomMKMapView

@synthesize delegate; // this is necessary so the setter could work

#pragma mark --initialization--

// Two initialization methods

//http://www.galloway.me.uk/tutorials/singleton-classes/

+ (CustomMKMapView *)sharedManager {
    static CustomMKMapView *sharedCustomMKMapView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedCustomMKMapView = [[CustomMKMapView alloc] init];
    });
    return sharedCustomMKMapView;
}

- (id) initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self){
        [self commonInit];

    }
    return self;
}

- (void)commonInit{    

    self.edgeInsets = UIEdgeInsetsMake(10, 10, 10, 70);
    self.isDebugModeOn = NO;
    self.isLongPressEnabled = NO;
    self.isMapStable = YES;
    self.transportType = MKDirectionsTransportTypeWalking;
    
    //----------------------
    // initialize the gesture recognizer
    //----------------------
    [self p_initGestureRecognizer];
    
    // Load the information sheet
    self.informationSheetManager = [[InformationSheetManager alloc] init];
    
    
    //-----------------
    // Initialize a hidden map
    //-----------------
    hiddenMap = [[GMSMapView alloc] init];
    hiddenMap.translatesAutoresizingMaskIntoConstraints = NO;
    hiddenMap.mapType = self.mapType;
    [self addSubview:hiddenMap];
    [hiddenMap setUserInteractionEnabled:NO];
    //    [hiddenMap setAlpha:0.5];
    [hiddenMap setHidden:YES];
    
    //-----------------
    // Constraints
    //-----------------
    NSMutableDictionary *viewDictionary = [[NSMutableDictionary alloc] init];
    viewDictionary[@"hiddenMap"] = hiddenMap;
    viewDictionary[@"realMap"] = self;
    
    NSMutableArray *constraintStringArray = [[NSMutableArray alloc] init];
    [constraintStringArray addObject:@"H:[hiddenMap(==realMap)]"];
    [constraintStringArray addObject:@"V:[hiddenMap(==realMap)]"];
    [constraintStringArray addObject:@"V:|-0-[hiddenMap]-0-|"];
    [constraintStringArray addObject:@"H:|-0-[hiddenMap]-0-|"];
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    for (NSString *constraintString in constraintStringArray){
        [constraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:constraintString
                                                 options:0 metrics:nil
                                                   views:viewDictionary]];
    }
    
    [self addConstraints:constraints];
}

// Check if the protocol methods are implemetned
- (void)setDelegate:(id<GMSMapViewDelegate>)aDelegate{
    delegate = aDelegate;
    [super setDelegate: aDelegate];
    
    _delegateRespondsTo.mapTouchBegin =
    [delegate respondsToSelector:@selector(mapTouchBegan: withEvent:)];
    
    _delegateRespondsTo.mapTouchMoved =
    [delegate respondsToSelector:@selector(mapTouchMoved: withEvent:)];
    
    _delegateRespondsTo.mapTouchEnded =
    [delegate respondsToSelector:@selector(mapTouchEnded: withEvent:)];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (NSString*)description{
    NSMutableArray *lineArray = [NSMutableArray array];
    NSString *line = [NSString stringWithFormat:@"Map center coordinate: (%f, %f)", self.camera.target.latitude, self.camera.target.longitude];
    [lineArray addObject:line];
    

    line = [NSString stringWithFormat:@"Map zoom: %f",
            self.camera.zoom];
    [lineArray addObject:line];
    return [lineArray componentsJoinedByString:@"\n"];
}

@end
