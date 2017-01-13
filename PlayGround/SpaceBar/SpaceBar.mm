//
//  SpaceBar.m
//  PlayGround
//
//  Created by Daniel on 2/1/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SpaceBar.h"
#import "Constants.h"
#import "CERangeSlider.h"
#import "GestureEngine.h"
#import "TokenCollectionView.h"
#import "ViewController.h"
#import "ArrayTool.h"

#define SPACEBAR_WIDTH 40


// SpaceBar extension
@interface SpaceBar ()
{
    NSTimer *iv_updateUITimer;
}


@end

@implementation SpaceBar

static SpaceBar *sharedInstance;

+(SpaceBar*)sharedManager{    
    if (!sharedInstance){
        [NSException raise:@"Programming error." format:@"Attempt to access uninitialized SpaceBar object."];
    }
    return sharedInstance;
}

//----------------
// initialization
//----------------
- (id)initWithMapView: (MKMapView *) myMapView {
    self = [super init];
    
    // Initialize the map
    self.mapView = myMapView;
    
    // This part is common for all display types
    [self initializeCommon];
    
    self.spaceBarMode = TOKENONLY;
    
    
    // self.mapView.frame.size.width - spaceBarWidth
    _frame = CGRectMake(0, 0,
                        SPACEBAR_WIDTH,
                        self.mapView.frame.size.height);
    
    // Init an annotation view to hold annotations
    self.annotationView = [[UIView alloc] initWithFrame:self.frame];
    self.annotationView.backgroundColor = [UIColor clearColor];
    
    
    // Init the slider
    self.sliderContainer = [[CERangeSlider alloc] initWithFrame:self.frame];
    self.sliderContainer.delegate = self;
    self.sliderContainer.trackPaddingInPoints = 60; //pad the top and bottom
    
    
    self.sliderContainer.curvatiousness = 0.0;
    
    // Add the gesture engine
    self.gestureEngine = [[GestureEngine alloc] initWithSpaceBar:self];
    
    self.isBarToolHidden = YES;
    self.isStudyModeEnabled = NO;
    self.isMultipleTokenSelectionEnabled = YES;
    
    //--------------------------------
    // Initialize a token collection view
    //--------------------------------
    self.tokenCollectionView = [TokenCollectionView sharedManager];
    self.tokenCollectionView.isVisible = YES;
    [self.tokenCollectionView reloadData];
    
    //--------------------------------
    // Initialize an array tool
    //--------------------------------
    ArrayTool *arrayTool = [ArrayTool sharedManager];
    
    sharedInstance = self;
    
    return self;
}

//-------------------
// Control the visibility of the bar tool
//-------------------
- (void)setIsBarToolHidden:(BOOL)isBarToolHidden{
    _isBarToolHidden = isBarToolHidden;
    
    if (isBarToolHidden){
        [self.annotationView removeFromSuperview];
        [self.sliderContainer removeFromSuperview];
        [self.gestureEngine removeFromSuperview];
        
        [self removeRouteAnnotations];
        self.activeRoute = nil;
        // Reset Spacebar
        [self resetSpaceBar];
        [self.gestureEngine setUserInteractionEnabled:YES];
        [self.sliderContainer setUserInteractionEnabled: NO];
    }else{
        [self.mapView addSubview:self.annotationView];
        [self.mapView addSubview:self.sliderContainer];
        [self.mapView addSubview:self.gestureEngine];
    }
}

// Change the size of the frame
- (void)setFrame:(CGRect)frame{
    _frame = frame;
    self.annotationView.frame = frame;
    self.sliderContainer.frame = frame;
    [self.sliderContainer setLayerFrames]; //redraw the layer
    self.gestureEngine.frame = frame;
}

- (void)setDelegate:(id <SpaceBarDelegate>)aDelegate {
    if (_delegate != aDelegate) {
        _delegate = aDelegate;
        
        _delegateRespondsTo.spaceBarOnePointTouched =
        [_delegate respondsToSelector:@selector(spaceBarOnePointTouched:)];
        _delegateRespondsTo.spaceBarTwoPointsTouched =
        [_delegate respondsToSelector:@selector(spaceBarTwoPointsTouchedLow:high:)];
        _delegateRespondsTo.spaceBarElevatorMoved =
        [_delegate respondsToSelector:@selector(spaceBarElevatorMovedLow: high: fromLowToHigh:)];
    }
}

// Initialize common parts among all display types
- (void) initializeCommon {
    
    self.tokenCollection = [TokenCollection sharedManager];
    
    self.touchingSet = [[NSMutableSet alloc] init];
    self.draggingSet = [[NSMutableSet alloc] init];        
    self.anchorSet = [[NSMutableSet alloc] init];
    self.anchorCandidateSet = [[NSMutableSet alloc] init];
        
    self.isConstrainEngineON = YES;
    
    self.smallValueOnTopOfBar = YES;

    self.isAutoOrderSpaceTokenEnabled = YES;
    
    self.isSpaceTokenEnabled = NO;
    
    self.isAnchorAllowed = YES;
    
    // listen to several notification of interest
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserver:self
               selector:@selector(addToSetBasedOnNotification:)
                   name:AddToTouchingSetNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(addToSetBasedOnNotification:)
                   name:AddToDraggingSetNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(removeFromSetBasedOnNotification:)
                   name:RemoveFromTouchingSetNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(removeFromSetBasedOnNotification:)
                   name:RemoveFromDraggingSetNotification
                 object:nil];
        
    // Initialize the timer
    float timer_interval = 0.06;
    iv_updateUITimer = [NSTimer timerWithTimeInterval:timer_interval
                                             target:self
                                           selector:@selector(timerFired)
                                           userInfo:nil
                                            repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:iv_updateUITimer forMode:NSRunLoopCommonModes];
}


- (void)setSpaceBarMode:(SpaceBarMode)spaceBarMode{
    if (spaceBarMode == TOKENONLY){
        // SpaceToken only mode
        [self removeRouteAnnotations];
        [self.gestureEngine setUserInteractionEnabled:YES];
        [self.sliderContainer setUserInteractionEnabled: NO];
    }else{
        // Path mode
        [self.gestureEngine setUserInteractionEnabled:NO];
        [self.sliderContainer setUserInteractionEnabled: YES];
    }
}

//----------------
// timer
//----------------
-(void)timerFired{
    if (self.isConstrainEngineON)
        [self updateBasedOnConstraints];
}

- (void)updateBasedOnConstraints{
    // if tokenCollection.tokenArray is not empty, update the map
    if ([[self.tokenCollection getTokenArray] count] > 0){
        //        [self orderSpaceTokens];
        [self fillMapXYsForSet:[self.tokenCollection getTokenArray]];
    }
    
    if ([self.draggingSet count] > 0
        && [self.touchingSet count] == 0)
    {
        [self fillDraggingMapXYs];
        [self updateMapToFitPOIPreferences:self.draggingSet];
    }else{
        if ([self.touchingSet count] > 0){
            [self zoomMapToFitTouchSet];
        }
    }
    
    // If both the anchorSet and draggingSet are empty, turn off the SpaceToken mode
    if ([self.anchorSet count] == 0 &&
        [self.draggingSet count] ==0)
    {
        self.isSpaceTokenEnabled = NO;
    }else{
//        // Output the count of anchor and dragging set
//        NSLog(@"Anchor count: %d", (int)[self.anchorSet count]);
//        NSLog(@"Dragging count: %d", (int)[self.draggingSet count]);
    }
}


- (void) resetSpaceBar{
    // The valid range of lowerValue and upperValue of the elevator should be [0, 1]
    // Setting the lowerValue and upperValue to be both -1 will make the elevator invisible
    float temp[2] = {nanf(""), nanf("")};
    [self updateElevatorFromPercentagePair:temp];
}


- (NSString*) description{
    NSMutableArray *line = [NSMutableArray array];
    [line addObject:[NSString stringWithFormat:@"TouchingSet #%lu", (unsigned long)[self.touchingSet count]]];
    [line addObject:[NSString stringWithFormat:@"DraggingSet #%lu", (unsigned long)[self.draggingSet count]]];
    [line addObject:[NSString stringWithFormat:@"AnchorSet #%lu", (unsigned long)[self.anchorSet count]]];
    [line addObject:[NSString stringWithFormat:@"AnchorCandidateSet #%lu", (unsigned long)[self.anchorCandidateSet count]]];    
    return [line componentsJoinedByString:@"\n"];
}


//----------------
// desctructor
//----------------
-(void)dealloc {
    //cleanup code
    NSLog(@"Goodbye!");
}

@end
