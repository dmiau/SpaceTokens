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
    
    return self;
}



- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // UIView will be "transparent" for touch events if we return NO
    
    if (arrayToolMode == ArrayMode){
        
        if ((point.x < self.tokenWidth)
            &&(point.y > 0)){
            NSLog(@"Point inside");
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


#pragma mark <UICollectionViewDataSource>
// TODO: need to implement a viewWillAppear
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    // Reset TokenCollection
    [[TokenCollection sharedManager] removeAllTokensForStructure:self];
    
    
    if ([self.arrayEntity.contentArray count]==1
        && !masterToken)
    {
        // Insert a master token on the top
        [self initMasterToken];
    }
    
    if ([self.arrayEntity.contentArray count]>=2
        && !pathModeButton)
    {
        // Insert a path switch on the bottom
        [self initPathModeSwitch];
    }
    
    // Update the bound of the master token
    [self.arrayEntity updateBoundingMapRect];

    
    NSInteger outCount;
    if (arrayToolMode == ArrayMode){
        outCount = [self.arrayEntity.contentArray count];
    }else{
        outCount = 0;
    }
    return outCount;
}

-(void) insertToken: (SpaceToken*) token{
    
    SpatialEntity *anEntity = token.spatialEntity;
    
    if ([anEntity isKindOfClass:[ArrayEntity class]]){
        [self.arrayEntity.contentArray
         addObjectsFromArray: ((ArrayEntity*)anEntity).contentArray];
    }else{
        [self.arrayEntity.contentArray addObject:token.spatialEntity];
    }
    
    // refresh the token panel
    [self reloadData];
}

-(void) insertMaster:(SpaceToken*) token{
    if (masterToken){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"A master token already exists."
                                                        message:@"Please remove the master token first before adding one."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

    TokenCollection *tokenCollection = [TokenCollection sharedManager];
    masterToken = [tokenCollection addTokenFromSpatialEntity:token.spatialEntity];
    masterToken.home = self;
    
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(60, 20);
    [self addSubview:masterToken];
    
    self.arrayEntity = masterToken.spatialEntity;
    [self reloadData];
}

-(void)removeToken: (SpaceToken*) token{
    [token removeFromSuperview];
    [[TokenCollection sharedManager] removeToken:token];
    
    // Depending on the token, different things need to be done
    if (token.spatialEntity == self.arrayEntity){
        // masterToken is removed
        self.arrayEntity = [[ArrayEntity alloc] init];
    }else{
        [self.arrayEntity.contentArray removeObject:token.spatialEntity];
    }

    if ([self.arrayEntity.contentArray count] == 0){
        // Remove the masterToken
        [masterToken removeFromSuperview];
        masterToken = nil;
        
        // Remove the pathButton
        [pathModeButton removeFromSuperview];
        pathModeButton = nil;
    }
    
    if ([self.arrayEntity.contentArray count] < 2){
        // Remove the pathButton
        [pathModeButton removeFromSuperview];
        pathModeButton = nil;
    }
    
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
// Creating a master token
//------------------
- (void)initMasterToken{
    TokenCollection *tokenCollection = [TokenCollection sharedManager];
    masterToken = [tokenCollection addTokenFromSpatialEntity:self.arrayEntity];
    masterToken.home = self;
    
    CGRect frame = CGRectZero;
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

        Route *aRoute = [[Route alloc] init];
        void (^requestCompletionBlock)(void)=^{
            // Push the route to SpaceBar
            [[ViewController sharedManager] showRoute:aRoute
                                       zoomToOverview:YES];
        };
        aRoute.routeReadyBlock = requestCompletionBlock;
        [aRoute requestRouteFromEntities:self.arrayEntity.contentArray];
        
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
