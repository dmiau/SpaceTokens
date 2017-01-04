//
//  ArrayTool.m
//  SpaceBar
//
//  Created by Daniel on 1/1/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "ArrayTool.h"

#import "TokenCollection.h"
#import "CustomMKMapView.h"
#import "SpaceBar.h"

#import "ArrayEntity.h"

typedef enum {ArrayMode, PathMode} ArrayToolMode;

@implementation ArrayTool{
    UIButton *pathModeButton;
    SpaceToken *masterToken;
    ArrayToolMode arrayToolMode;
}


+(id)sharedManager{
    static ArrayTool *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ArrayTool alloc] initSingleton];
    });
    
    return sharedInstance;
}

// Overwrite super's initSingleton method
- (id) initSingleton{
    // Get the map view
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    // Configure the layout object
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake
    (60, 0, 0, mapView.frame.size.width-60);
    
    
    // Initialize a collection view
    self =
    [[ArrayTool alloc] initWithFrame:mapView.frame collectionViewLayout:layout];
    
    self.tokenWidth = 60;
    [self setTopAlignmentOffset:0];
    
    arrayToolMode = ArrayMode;
    
    // Insert a master token on the top
    [self initMasterToken];
    
    // Insert a path switch on the bottom
    [self initPathModeSwitch];
    
    return self;
}



- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // UIView will be "transparent" for touch events if we return NO
    return ((point.x < self.tokenWidth)
            &&(point.y > 0));
}


#pragma mark <UICollectionViewDataSource>
// TODO: need to implement a viewWillAppear
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if ([self.arrayEntity.contentArray count] > 12){
        [TokenCollection sharedManager].isCustomGestureRecognizerEnabled = NO;
    }else{
        [TokenCollection sharedManager].isCustomGestureRecognizerEnabled = YES;
    }
    
    NSInteger outCount;
    if (arrayToolMode == ArrayMode){
        outCount = [self.arrayEntity.contentArray count];
    }else{
        outCount = 0;
    }
    return outCount;
}

// This decide whether an achor is in the insertion zone or not.
-(BOOL)isTouchInInsertionZone:(UITouch*)touch{
    
    if (!self.isVisible)
        return NO;
    
    CGPoint tokenPoint = [touch locationInView:self];
    
    if (tokenPoint.x < self.tokenWidth * 0.5){
        return YES;
    }else{
        return NO;
    }
}

- (void)initMasterToken{
    TokenCollection *tokenCollection = [TokenCollection sharedManager];
    masterToken = [tokenCollection findSpaceTokenFromEntity:self.arrayEntity];
    if (!masterToken){
        masterToken = [tokenCollection addTokenFromSpatialEntity:self.arrayEntity];
    }
    CGRect frame = CGRectZero;
    frame.origin = CGPointMake(0, -30);
    frame.size = CGSizeMake(60, 20);
    [self addSubview:masterToken];
}

- (void)initPathModeSwitch{
    pathModeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [pathModeButton setTitle:@"Path" forState:UIControlStateNormal];
    pathModeButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [pathModeButton setBackgroundColor:[UIColor grayColor]];
    [pathModeButton addTarget:self action:@selector(pathModeButtonAction)
              forControlEvents:UIControlEventTouchDown];
    
    // add drop shadow
    //            self.layer.cornerRadius = 8.0f;
    pathModeButton.layer.masksToBounds = NO;
    //            self.layer.borderWidth = 1.0f;
    
    pathModeButton.layer.shadowColor = [UIColor grayColor].CGColor;
    pathModeButton.layer.shadowOpacity = 0.8;
    pathModeButton.layer.shadowRadius = 12;
    pathModeButton.layer.shadowOffset = CGSizeMake(12.0f, 12.0f);
    
    // Added to the bottom
    CGRect frame = CGRectZero;
    frame.origin = CGPointMake(0, self.frame.size.height - 20);
    frame.size = CGSizeMake(60, 20);
    pathModeButton.frame = frame;
    [self addSubview:pathModeButton];
}

- (void)pathModeButtonAction{
    NSLog(@"Path mode button is pressed.");
    
    if (arrayToolMode == ArrayMode){
        // Switching to PathMode
        arrayToolMode = PathMode;
        
        // Clear all the token, expose the bar underneath

        // Construct a route and feed it to SpaceBar
        //    Route *aRoute = (Route*)aToken.spatialEntity;
        //    // Load the route to the bar tool
        //    [[ViewController sharedManager] showRoute:aRoute
        //                               zoomToOverview:YES];
        
        // Change pointInside detection method
        
    }else{
        // Switching to ArrayMode
        arrayToolMode = ArrayMode;
    }
    
    [self reloadData];
    
    

    
}

@end
