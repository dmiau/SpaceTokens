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

#import "AdditionTool.h"
#import "PathToken.h"
#import "EntityDatabase.h"



@implementation ArrayTool{
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
    
    self.arrayToolMode = ArrayMode;
    counter = 0;
    self.arrayEntity = [[Route alloc] init];
    self.arrayEntity.name = [NSString stringWithFormat:@"AC-%d", counter++];
    self.arrayEntity.appearanceMode = SETMODE;
    
    // Add a master token landing zone
    [self initMasterLandingZone];
    
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
    
    
    // Register drag action
    [self addDragActionHandlingBlock];
    
    return self;
}

-(void)initMasterLandingZone{
    // Add a master token landing zone
    UIView *masterLandingZone = [[UIView alloc] init];
    [masterLandingZone setBackgroundColor:[UIColor colorWithWhite:0.6 alpha:0.5]];
    CGSize arrayTokenSize = [ArrayToken getSize];
    CGRect masterLandingRect = CGRectMake(0, 20, arrayTokenSize.width, arrayTokenSize.height);
    masterLandingZone.frame = masterLandingRect;
    masterLandingZone.layer.cornerRadius = 10; // this value vary as per your desire
    [self addSubview:masterLandingZone];
    
    
    // Initialize an AdditionTool
    CGRect toolFrame = CGRectMake(0, 0, 60, 60);
    additionTool = [[AdditionTool alloc] initWithFrame:toolFrame];
    [masterLandingZone addSubview:additionTool];
    
    BOOL (^additionHandlingBlock)(SpaceToken*) = ^(SpaceToken* token){
        if ([self insertMaster:token]){
            // Flash the touched SpaceToken
            [token flashToken];
            return YES;
        }else{
            return NO;
        }
    };
    additionTool.additionHandlingBlock = additionHandlingBlock;
    additionTool.home = self;
}


-(void)addDragActionHandlingBlock{
    // Add a dragging handling block to TokenCollection
    dragActionHandlingBlock handlingBlock = ^BOOL(UITouch *touch, SpaceToken* token){
        
        if (!self.isVisible || token.home == self)
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


- (void)resetTool{
    // Remove the master token
    if (self.masterToken){
        [self removeToken:self.masterToken];
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // UIView will be "transparent" for touch events if we return NO
    
    if (self.arrayToolMode == ArrayMode){
        if ((point.x < self.tokenWidth)
            &&(point.y > 0)){
            return YES;
        }else{
            return NO;
        }
        
    }else if (self.arrayToolMode == PathMode){
        if (CGRectContainsPoint(self.masterToken.frame, point)){
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
    
    // Update the bound of the master token
    [self.arrayEntity updateBoundingMapRect];

    
    NSInteger outCount;
    if (self.arrayToolMode == ArrayMode){
        outCount = [[self.arrayEntity getContent] count];
    }else{
        outCount = 0;
    }
    return outCount;
}

//------------------
// Insert a master
//------------------
-(BOOL) insertMaster:(PathToken*) token{
    if (self.masterToken){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"A master token already exists."
                                                        message:@"Please remove the master token first before adding one."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    if (!token){
        // Create a master using the current self.arrayEntity
        self.masterToken = [[TokenCollection sharedManager]
                       addTokenFromSpatialEntity:self.arrayEntity];
    }else{
        // This part is called when a token is provided as a candidate to the master token
        
        if (![token.spatialEntity isKindOfClass:[Route class]]){
            return NO;
        }
        
        self.masterToken = [[TokenCollection sharedManager]
                       addTokenFromSpatialEntity:token.spatialEntity];
        
        self.arrayEntity = self.masterToken.spatialEntity;
    }
    self.masterToken.home = self;
    
    [self configureToolModeBasedOnMaster];
    
    // Observe the master token
    [self.arrayEntity addObserver:self forKeyPath:@"dirtyFlag"
                          options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    // Set up the frame
    CGRect masterFrame = CGRectMake(0, 20,
                                    self.masterToken.frame.size.width,
                                    self.masterToken.frame.size.height);
    self.masterToken.frame = masterFrame;
    [self addSubview:self.masterToken];
    
    void (^cloneCreationHandler)(SpaceToken* token) = ^(SpaceToken* token){
        
        if (![token isKindOfClass:[PathToken class]]){
            [NSException raise:@"Programming error." format:@"ArrayTool's master token needs to be of type PathToken."];
        }
        token.home = self;
        self.masterToken = token;
    };
    self.masterToken.didCreateClone = cloneCreationHandler;
    
    [self reloadData];
    return YES;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"dirtyFlag"] && object == self.arrayEntity)
    {
        [self configureToolModeBasedOnMaster];
    }
}

-(void)configureToolModeBasedOnMaster{
    // Configure the bar mode
    Route *aRoute = self.arrayEntity;
    if (aRoute.appearanceMode == ROUTEMODE ||
        aRoute.appearanceMode == SKETCHEDROUTE)
    {
        self.arrayToolMode = PathMode;
        [[ViewController sharedManager] showRoute:aRoute
                                   zoomToOverview:YES];
    }else{
        [[ViewController sharedManager] removeRoute];
        self.arrayToolMode = ArrayMode;
    }
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
    
    // refresh the token panel
    [self reloadData];
}

-(void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [super collectionView: collectionView moveItemAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
    // Update the line if there are more than two entities
    if ([[self.arrayEntity getContent] count]>1){
        [self.arrayEntity updateBoundingMapRect];
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
        [self.arrayEntity removeObserver:self forKeyPath:@"dirtyFlag"];
        
        // Remove the annotation before the master token is removed
        self.arrayEntity.isMapAnnotationEnabled = NO;
        self.arrayEntity = [[Route alloc] init];
        self.arrayEntity.name = [NSString stringWithFormat:@"AC-%d", counter++];
        self.arrayEntity.appearanceMode = SETMODE;
    }else{
        [self.arrayEntity removeObjectAtIndex:i];
    }

    if ([[self.arrayEntity getContent] count] == 0){
        // Remove the masterToken
        [self.masterToken removeFromSuperview];
        self.masterToken = nil;
    }
 
    if ([[self.arrayEntity getContent] count]>1){
        self.arrayEntity.isMapAnnotationEnabled = YES;
    }
    
    [self reloadData];
}

@end
