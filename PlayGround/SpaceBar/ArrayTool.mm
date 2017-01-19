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
    PathToken *masterToken;
    ArrayToolMode arrayToolMode;
    AdditionTool *additionTool;
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
    
    self.arrayEntity = [[Route alloc] init];
    
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
    return self;
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
        if (CGRectContainsPoint(masterToken.frame, point)){
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
        && !masterToken)
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
    if (masterToken){
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
        masterToken = [[TokenCollection sharedManager]
                       addTokenFromSpatialEntity:self.arrayEntity];
    }else{
        masterToken = [[TokenCollection sharedManager]
                       addTokenFromSpatialEntity:token.spatialEntity];
        
        self.arrayEntity = masterToken.spatialEntity;
    }
    
    masterToken.home = self;
    
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(60, 20);
    [self addSubview:masterToken];
    
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
        [self.arrayEntity updateRouteForContentArray];
    }
    
    // refresh the token panel
    [self reloadData];
}

-(void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [super collectionView: collectionView moveItemAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
    // Update the line if there are more than two entities
    if ([[self.arrayEntity getContent] count]>1){
        [self.arrayEntity updateRouteForContentArray];
    }
}

//------------------
// Remove a token
//------------------
-(void)removeToken: (SpaceToken*) token{
    
    // Get the index of the token
    int i = [self getIndexOfToken:token];
    [token removeFromSuperview];
    
    // Depending on the token, different things need to be done
    if (token.spatialEntity == self.arrayEntity){
        // masterToken is removed
        
        // Remove the annotation before the master token is removed
        self.arrayEntity.isMapAnnotationEnabled = NO;
        self.arrayEntity = [[Route alloc] init];
    }else{
        [self.arrayEntity removeObjectAtIndex:i];
    }

    if ([[self.arrayEntity getContent] count] == 0){
        // Remove the masterToken
        [masterToken removeFromSuperview];
        masterToken = nil;
    }
    
    // Remove the path button
    if ([[self.arrayEntity getContent] count] < 2){
        // Remove the pathButton
        [pathModeButton removeFromSuperview];
        pathModeButton = nil;
    }
    
    [self.arrayEntity updateRouteForContentArray];
    [self reloadData];
}

// This decide whether an achor is in the insertion zone or not.
-(BOOL)isTouchInInsertionZone:(UITouch*)touch{
    
    if (!self.isVisible)
        return NO;
    
    CGPoint tokenPoint = [touch locationInView:self];
    
    if (tokenPoint.x < self.tokenWidth * 0.5 &&
        tokenPoint.y > 60)
    {
        return YES;
    }else{
        return NO;
    }
}

-(BOOL)isTouchInMasterTokenZone:(UITouch*)touch{
    if (!self.isVisible)
        return NO;
    
    CGPoint tokenPoint = [touch locationInView:self];
    
    if (tokenPoint.x < self.tokenWidth * 0.5 &&
        tokenPoint.y < 60)
    {
        return YES;
    }else{
        return NO;
    }
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
    
    if (arrayToolMode == ArrayMode){
        // Switching to PathMode
        arrayToolMode = PathMode;
        
        // Clear all the token, expose the bar underneath

        Route *aRoute = [[Route alloc] init];
        void (^requestCompletionBlock)(void)=^{
            // Push the route to SpaceBar
            [[ViewController sharedManager] showRoute:aRoute
                                       zoomToOverview:YES];
        };
        aRoute.routeReadyBlock = requestCompletionBlock;
        [aRoute requestRouteFromEntities:[self.arrayEntity getContent]];
        
        // Change pointInside detection method
        
    }else{
        // Disable the scroll bar
        [[ViewController sharedManager] removeRoute];
        // Switching to ArrayMode
        arrayToolMode = ArrayMode;
    }
    
    [self reloadData];
}

@end
