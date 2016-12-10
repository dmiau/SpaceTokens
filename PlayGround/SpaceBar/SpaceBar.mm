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


// SpaceBar extension
@interface SpaceBar ()
{
    NSTimer *iv_updateUITimer;
}


@end

@implementation SpaceBar

static SpaceBar *sharedInstance;

+(id)sharedManager{return sharedInstance;}

//----------------
// initialization
//----------------
- (id)initWithMapView: (MKMapView *) myMapView {
    self = [super init];
    if (self) {
        // Initialize the map
        self.mapView = myMapView;
        
        // This part is common for all display types
        [self initializeCommon];
        
        self.spaceBarMode = TOKENONLY;
        
        // Init the frame
        float spaceBarWidth = 40;
        
        // self.mapView.frame.size.width - spaceBarWidth
        _frame = CGRectMake(0, 0,
                                spaceBarWidth,
                                self.mapView.frame.size.height);
        
        // Init an annotation view to hold annotations
        self.annotationView = [[UIView alloc] initWithFrame:self.frame];
        self.annotationView.backgroundColor = [UIColor clearColor];
        [self.mapView addSubview:self.annotationView];
        
        // Init the slider
        self.sliderContainer = [[CERangeSlider alloc] initWithFrame:self.frame];
        self.sliderContainer.delegate = self;
        self.sliderContainer.trackPaddingInPoints = 30;

        [self.mapView addSubview:self.sliderContainer];
        self.sliderContainer.curvatiousness = 0.0;
        
        // Add the gesture engine
        self.gestureEngine = [[GestureEngine alloc] initWithSpaceBar:self];
        [self.mapView addSubview:self.gestureEngine];
        
        //--------------------------------
        // Initialize a token collection view
        //--------------------------------
        UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
        
        // Configure the layout object
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.sectionInset = UIEdgeInsetsMake
        (10, self.mapView.frame.size.width-60, 0, 0);
        
        // Initialize a collection view controller
        self.tokenCollectionView =
        [[TokenCollectionView alloc] initWithFrame:self.mapView.frame collectionViewLayout:layout];
        
        self.tokenCollectionView.tokenWidth = 60;
        
        // Add the tokenCollectionView panel
        self.isTokenCollectionViewEnabled = YES;
        
        sharedInstance = self;
    }
    return self;
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
    self.dotSet = [[NSMutableSet alloc] init];
    
    self.touchingSet = [[NSMutableSet alloc] init];
    self.draggingSet = [[NSMutableSet alloc] init];        
    self.anchorSet = [[NSMutableSet alloc] init];
    self.anchorCandidateSet = [[NSMutableSet alloc] init];
    
    self.isConstrainEngineON = YES;
    
    self.smallValueOnTopOfBar = true;
    
    self.isYouAreHereEnabled = YES;

    self.isAutoOrderSpaceTokenEnabled = YES;
    
    self.isSpaceTokenEnabled = YES;
    
    // listen to several notification of interest
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
        selector:@selector(addToSetBasedOnNotification:)
        name:AddToButtonArrayNotification
        object:[[ UIApplication sharedApplication] delegate]];

    [center addObserver:self
               selector:@selector(addToSetBasedOnNotification:)
                   name:AddToTouchingSetNotification
                 object:nil];
    //[[ UIApplication sharedApplication] delegate]
    
    [center addObserver:self
               selector:@selector(addToSetBasedOnNotification:)
                   name:AddToDraggingSetNotification
                 object:nil];
    

    [center addObserver:self
               selector:@selector(removeFromSetBasedOnNotification:)
                   name:RemoveFromButtonArrayNotification
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
        // remove all SpaceTokens
        [self removeAllSpaceTokens];
        [self.gestureEngine setUserInteractionEnabled:NO];
        [self.sliderContainer setUserInteractionEnabled: YES];
    }
}

// Controls the visibility of the tokenCollectionView panel
- (void)setIsTokenCollectionViewEnabled:(BOOL)isTokenCollectionViewEnabled{
    _isTokenCollectionViewEnabled = isTokenCollectionViewEnabled;
    // Remove all SpaceTokens first
    [self removeAllSpaceTokens];

    if (_isTokenCollectionViewEnabled){
        self.tokenCollectionView.frame = self.mapView.frame;
        
        ViewController *rootController = [ViewController sharedManager];
        [rootController.view addSubview:self.tokenCollectionView];
        [self.tokenCollectionView reloadData];
    }else{
        [self.tokenCollectionView removeFromSuperview];
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
    if ([self.tokenCollection.tokenArray count] > 0){
        //        [self orderSpaceTokens];
        [self fillMapXYsForSet:self.tokenCollection.tokenArray];
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


//----------------
// desctructor
//----------------
-(void)dealloc {
    //cleanup code
    NSLog(@"Goodbye!");
}

@end
