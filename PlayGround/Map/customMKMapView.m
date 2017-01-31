//
//  CustomMKMapView.m
//  SpaceBar
//
//  Created by Daniel on 7/4/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "CustomMKMapView.h"
#include <stdlib.h>


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
    
    //----------------------
    // initialize the gesture recognizer
    //----------------------
    [self p_initGestureRecognizer];
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
