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
#import "Route.h"
#import "ViewController.h"

#import "ArrayEntity.h"
#import "AdditionTool.h"
#import "PathToken.h"

typedef enum {ArrayMode, PathMode} ArrayToolMode;

@implementation ArrayTool{
    UIButton *pathModeButton;
    ArrayToolMode arrayToolMode;
    AdditionTool *additionTool;
    int counter;
}


+(ArrayTool*)sharedManager{
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
    counter = 0;
    self.arrayEntity = [[Route alloc] init];
    self.arrayEntity.name = [NSString stringWithFormat:@"AC-%d", counter++];
    self.arrayEntity.appearanceMode = ARRAYMODE;
    
    // Initialize an AdditionTool
    CGRect toolFrame = CGRectMake(0, 60, 60, self.frame.size.height-120);
    additionTool = [[AdditionTool alloc] initWithFrame:toolFrame];
    [self addSubview:additionTool];
    
    BOOL (^additionHandlingBlock)(SpaceToken*) = ^(SpaceToken* token){
        [self insertToken:token];
        
        // Flash the touched SpaceToken
        [token flashToken];
        return YES;
    };
    additionTool.additionHandlingBlock = additionHandlingBlock;
    additionTool.home = self;
    
    [self addDragActionHandlingBlock];
    
    return self;
}

-(void)addDragActionHandlingBlock{
    // Add a dragging handling block to TokenCollection
    dragActionHandlingBlock handlingBlock = ^BOOL(UITouch *touch, SpaceToken* token){
        
        if (!self.isVisible)
            return NO;
        
        CGPoint tokenPoint = [touch locationInView:self];
        
        // Check if the touch is in the master token insertion zone
        if (tokenPoint.x < self.tokenWidth * 0.5 &&
            tokenPoint.y < 60)
        {
            [self insertMaster:token];
            return YES;
        }
        
        // Check if the touch is in the general token insertion zone
        if (tokenPoint.x < self.tokenWidth * 0.5 &&
            tokenPoint.y > 60)
        {
            [self insertToken:token];
            return YES;
        }else{
            return NO;
        }
        
    };
    
    [[[TokenCollection sharedManager] handlingBlockArray] addObject: handlingBlock];
}


- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // UIView will be "transparent" for touch events if we return NO
    
    if (arrayToolMode == ArrayMode){
        if ((point.x < self.tokenWidth)
            &&(point.y > 0)){
            return YES;
        }else{
            return NO;
        }
        
    }else if (arrayToolMode == PathMode){
        if (CGRectContainsPoint(self.masterToken.frame, point)){
            return YES;
        }else if (CGRectContainsPoint(pathModeButton.frame, point)){
            return YES;
        }else{
            return NO;
        }
    }else{
        [NSException raise:@"Programming error." format:@"Unrecognized arrayMode"];
        return NO;
    }
}

// MARK: Setters
-(void)setArrayEntity:(Route *)arrayEntity{
    [super setArrayEntity:arrayEntity];
}


#pragma mark <UICollectionViewDataSource>
// TODO: need to implement a viewWillAppear
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if ([[self.arrayEntity getContent] count]>1
        && !self.masterToken)
    {
        // Insert a master token on the top
        [self insertMaster:nil];
    }
    
    if ([[self.arrayEntity getContent] count]>=2
        && !pathModeButton)
    {
        // Insert a path switch on the bottom
        [self initPathModeSwitch];
    }
    
    // Update the bound of the master token
    [self.arrayEntity updateBoundingMapRect];

    
    NSInteger outCount;
    if (arrayToolMode == ArrayMode){
        outCount = [[self.arrayEntity getContent] count];
    }else{
        outCount = 0;
    }
    return outCount;
}

//------------------
// Insert a master
//------------------
-(void) insertMaster:(PathToken*) token{
    if (self.masterToken){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"A master token already exists."
                                                        message:@"Please remove the master token first before adding one."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (!token){
        // Create a master using the current self.arrayEntity
        self.masterToken = [[TokenCollection sharedManager]
                       addTokenFromSpatialEntity:self.arrayEntity];
    }else{
        // This is usually called when a user drags a collection token to the position of a master token
        self.masterToken = [[TokenCollection sharedManager]
                       addTokenFromSpatialEntity:token.spatialEntity];
        
        self.arrayEntity = self.masterToken.spatialEntity;
    }
    
    self.masterToken.home = self;
    
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(60, 20);
    [self addSubview:self.masterToken];
    
    void (^cloneCreationHandler)(SpaceToken* token) = ^(SpaceToken* token){
        
        if (![token isKindOfClass:[PathToken class]]){
            [NSException raise:@"Programming error." format:@"ArrayTool's master token needs to be of type PathToken."];
        }
        token.home = self;
        self.masterToken = token;
    };
    self.masterToken.didCreateClone = cloneCreationHandler;
    
    // After the route is updated, its annotation needs to be updated, too.
    void (^requestCompletionBlock)(void)=^{
        // Show the annotation after the route is ready
        self.arrayEntity.isMapAnnotationEnabled = YES;
    };
    self.arrayEntity.routeReadyBlock = requestCompletionBlock;
    
    [self reloadData];
}


//------------------
// Insert a token
//------------------
-(void) insertToken: (SpaceToken*) token{
    
    SpatialEntity *anEntity = token.spatialEntity;
    
    if ([anEntity isKindOfClass:[ArrayEntity class]]){
        [self.arrayEntity
         addObjectsFromArray: [(ArrayEntity*)anEntity getContent]];
    }else{
        [self.arrayEntity addObject:token.spatialEntity];
    }
    
    // Update the line if there are more than two entities
    if ([[self.arrayEntity getContent] count]>1){
        [self.arrayEntity updateArrayForContentArray];
        self.arrayEntity.isMapAnnotationEnabled = YES;
    }
    
    // refresh the token panel
    [self reloadData];
}

-(void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [super collectionView: collectionView moveItemAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
    // Update the line if there are more than two entities
    if ([[self.arrayEntity getContent] count]>1){
        [self.arrayEntity updateArrayForContentArray];
        self.arrayEntity.isMapAnnotationEnabled = YES;
    }
}

//------------------
// Remove a token
//------------------
-(void)removeToken: (SpaceToken*) token{
    
    // Get the index of the token
    int i = token.index; // The index of a SpaceToken
    
    [token removeFromSuperview];
    
    // Depending on the token, different things need to be done
    if (token.spatialEntity == self.arrayEntity){
        // masterToken is removed
        
        // Remove the annotation before the master token is removed
        self.arrayEntity.isMapAnnotationEnabled = NO;
        self.arrayEntity = [[Route alloc] init];
        self.arrayEntity.name = [NSString stringWithFormat:@"AC-%d", counter++];
        self.arrayEntity.appearanceMode = ARRAYMODE;
    }else{
        [self.arrayEntity removeObjectAtIndex:i];
    }

    if ([[self.arrayEntity getContent] count] == 0){
        // Remove the masterToken
        [self.masterToken removeFromSuperview];
        self.masterToken = nil;
    }
    
    // Remove the path button
    if ([[self.arrayEntity getContent] count] < 2){
        // Remove the pathButton
        [pathModeButton removeFromSuperview];
        pathModeButton = nil;
    }
 
    [self.arrayEntity updateArrayForContentArray];
    if ([[self.arrayEntity getContent] count]>1){
        self.arrayEntity.isMapAnnotationEnabled = YES;
    }
    
    [self reloadData];
}

//------------------
// Creating a path button
//------------------

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
    Route *aRoute = self.arrayEntity;
    self.arrayEntity.isMapAnnotationEnabled = NO;
    if (arrayToolMode == ArrayMode){
        // Switching to PathMode
        arrayToolMode = PathMode;
        
        // Clear all the token, expose the bar underneath
        void (^requestCompletionBlock)(void)=^{
            // Push the route to SpaceBar
            [[ViewController sharedManager] showRoute:aRoute
                                       zoomToOverview:YES];
        };
        aRoute.routeReadyBlock = requestCompletionBlock;
        aRoute.appearanceMode = ROUTEMODE;
        [aRoute updateRouteForContentArray];
    }else{
        
        // Disable the scroll bar
        [[ViewController sharedManager] removeRoute];
        // Switching to ArrayMode
        arrayToolMode = ArrayMode;
        aRoute.appearanceMode = ARRAYMODE;
        [aRoute updateArrayForContentArray];
    }
    self.arrayEntity.isMapAnnotationEnabled = YES;
    [self reloadData];
}

@end
