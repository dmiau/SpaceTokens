//
//  SetTool.m
//  NavTools
//
//  Created by Daniel on 1/9/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "SetTool.h"
#import "CustomMKMapView.h"
#import "MiniMapView.h"
#import "ArrayEntity.h"
#import "SpaceToken.h"
#import "PathToken.h"
#import "TokenCollection.h"
#import "Constants.h"
#import "ViewController.h"
#import "SetCollectionView.h"

#import "AdditionTool.h"
#import "Route.h"

//-------------------
// Parameters
//-------------------
#define TOOL_WIDTH 150
#define TOOL_HEIGHT 150

@implementation SetTool{
    BOOL moveMode;
    AdditionTool *additionTool;
    int counter;
}

// MARK: Initialization
+(SetTool*)sharedManager{
    static SetTool *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SetTool *aView = (SetTool*)[[[NSBundle mainBundle] loadNibNamed:@"SetTool" owner:nil options:nil] firstObject];
        [aView initializeObject];
        sharedInstance = aView;
    });
    return sharedInstance;
}

-(void)initializeObject{
    //----------------
    // Initialize properties
    //----------------
    self.isVisible = NO;
    self.setToolMode = EmptyMode;
    self.masterToken = nil;
    moveMode = NO; //
    counter = 0;
    
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    self.frame = mapView.frame;

    //----------------
    // Set up the toolView
    //----------------
    [self.toolView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.2]];
    
    //----------------
    // Set up the mini map
    //----------------
    [self.miniMapView setUserInteractionEnabled:NO];
    self.miniMapView.settings.compassButton = NO;
    
    // Make the mini map hidden by default
    [self.miniMapView setHidden:YES];
    
    // listen to the map change event
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(updateBoxInMiniMap)
                   name:MapUpdatedNotification
                 object:nil];
    
    //----------------
    // Set up the collection view
    //----------------
    [self.setCollectionView initObject];
    [self.setCollectionView setHidden:NO];
    
    self.arrayEntity = [[Route alloc] init];
    self.arrayEntity.name = [NSString stringWithFormat:@"SC-%d", counter++];
    self.arrayEntity.appearanceMode = SETMODE;
    
    //----------------
    // Add an Addition Tool
    //----------------
    CGRect toolFrame = self.setCollectionView.bounds;
    additionTool = [[AdditionTool alloc] initWithFrame:toolFrame];
    [self.setCollectionView addSubview:additionTool];
    
    BOOL (^additionHandlingBlock)(SpaceToken*) = ^(SpaceToken* token){
        [self insertToken:token];
        
        // Flash the touched SpaceToken
        [token flashToken];
        return YES;
    };
    additionTool.home = self;
    additionTool.additionHandlingBlock = additionHandlingBlock;
    
    [self addDragActionHandlingBlock];
}


-(void)addDragActionHandlingBlock{
    // Add a dragging handling block to TokenCollection
    dragActionHandlingBlock handlingBlock = ^BOOL(UITouch *touch, SpaceToken* token){
        
        if (!self.isVisible || token.home == self)
            return NO;
        
        CGPoint touchPoint = [touch locationInView:self.toolView];
        
        // Check if the touch is in the master token insertion zone
        if (CGRectContainsPoint(CGRectMake(0, 0, 60, 30), touchPoint))
        {
            if ([self insertMaster:token]){
                return YES;
            }else{
                return NO;
            }
        }
        
        // Check if the touch is in the general token insertion zone
        if (CGRectContainsPoint(CGRectMake(0, 30, TOOL_WIDTH, TOOL_HEIGHT - 30), touchPoint))
        {
            [self insertToken:token];
            return YES;
        }else{
            return NO;
        }
        
    };
    
    [[[TokenCollection sharedManager] handlingBlockArray] addObject: handlingBlock];
}

-(void)updateView{
    // Create an entity set
    NSSet *entitySet = [NSSet setWithArray:[self.arrayEntity getContent]];
    
    if ([[self.arrayEntity getContent] count]==1
        && !self.masterToken)
    {
        // Insert a master token on the top
        [self insertMaster: nil];
        self.setToolMode = SetMode;
    }
    
    if ([[self.arrayEntity getContent] count] == 0){
        self.setToolMode = EmptyMode;
        // Remove the master token
        [self removeMaster];
    }
    
    if ([[self.arrayEntity getContent] count] >= 1){
        if (self.setToolMode == EmptyMode){
            self.setToolMode = MapMode;
        }
    }

    // Update the bound of the master token
    [self.arrayEntity updateBoundingMapRect];
    
    // refresh the map
    [self.miniMapView zoomToFitEntities: entitySet];
    
    [self.setCollectionView reloadData];
    
    //---------------
    // Set up the annotations
    //---------------
    // Clear the existing annotation
    [self.miniMapView clear];
    // Add annotations to the mini map
    for (SpatialEntity *entity in [self.arrayEntity getContent]){
        [entity setMapAnnotationEnabled:YES onMap:self.miniMapView];
    }
}

-(void)updateBoxInMiniMap{
    [self.miniMapView updateBox:[CustomMKMapView sharedManager]];
}

// MARK: Setters
-(void)setIsVisible:(BOOL)isVisible{
    _isVisible = isVisible;
    
    if (isVisible){
        CustomMKMapView *mapView = [CustomMKMapView sharedManager];
        self.frame = mapView.frame;
        
        ViewController *rootController = [ViewController sharedManager];
        [rootController.view addSubview:self];
        [self updateView];
        
        // Move the top view to the front
        // (so the CollectionView will not block the top view after it is scrolled.)
        [rootController.view bringSubviewToFront: (UIView*) rootController.mainViewManager.activePanel];
    }else{
        [self removeFromSuperview];
    }
}

-(void)setArrayEntity:(Route *)arrayEntity{
    _arrayEntity = arrayEntity;
    self.setCollectionView.arrayEntity = arrayEntity;
}

-(void)setSetToolMode:(SetToolMode)setToolMode{
    
    if ([[self.arrayEntity getContent] count] == 0){
        setToolMode = EmptyMode;
    }
    
    _setToolMode = setToolMode;
    
    switch (setToolMode) {
        case SetMode:
            [self.miniMapView setHidden:YES];
            [self.setCollectionView setHidden:NO];
            [self bringSubviewToFront:self.setCollectionView];
            break;
        case MapMode:
            [self.miniMapView setHidden:NO];
            [self.setCollectionView setHidden:YES];
            [self bringSubviewToFront:self.miniMapView];
            break;
        case EmptyMode:
            [self.miniMapView setHidden:YES];
            [self.setCollectionView setHidden:YES];
            break;
        default:
            [self.miniMapView setHidden:YES];
            [self.setCollectionView setHidden:YES];
            break;
    }
}

// MARK: hit tests
-(BOOL)isTouchInMasterTokenZone:(UITouch*)touch{
    if (!self.isVisible)
        return NO;
    
    CGPoint touchPoint = [touch locationInView:self.toolView];
    
    if (CGRectContainsPoint(CGRectMake(0, 0, 60, 30), touchPoint)){
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // UIView will be "transparent" for touch events if we return NO
    return (CGRectContainsPoint(self.toolView.frame, point));
}

// MARK: Token management

-(BOOL)insertMaster:(PathToken*) token{
    
    // Remove the current master
    if (self.masterToken){
        [self.masterToken removeFromSuperview];
    }
    
    if (!token){
        // Create a master using the current self.arrayEntity
        self.masterToken = [[TokenCollection sharedManager]
                            addTokenFromSpatialEntity:self.arrayEntity];
    }else{
        // This part is called when a token is provided as a candidate to the master token
        
        if (![token.spatialEntity isKindOfClass:[ArrayEntity class]]){
            return NO;
        }
        
        self.masterToken = [[TokenCollection sharedManager]
                            addTokenFromSpatialEntity:token.spatialEntity];
        
        self.arrayEntity = self.masterToken.spatialEntity;
    }

    self.masterToken.home = self;
    
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(60, 20);
    [self.toolView addSubview:self.masterToken];
    
    void (^cloneCreationHandler)(SpaceToken* token) = ^(SpaceToken* token){
        
        if (![token isKindOfClass:[PathToken class]]){
            [NSException raise:@"Programming error." format:@"SetTool's master token needs to be of type PathToken."];
        }
        token.home = self;
        self.masterToken = token;
    };
    self.masterToken.didCreateClone = cloneCreationHandler;
    
    self.arrayEntity = self.masterToken.spatialEntity;
    [self updateView];
    return YES;
}

-(void) insertToken: (SpaceToken*) token{
    // Need to perform set operation
    NSMutableSet *originalSet = [NSMutableSet setWithArray:[self.arrayEntity getContent]];
    [originalSet unionSet:[NSSet setWithObject:token.spatialEntity]];
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:[originalSet allObjects]];
    // Create a new SpaceToken based on anchor
    [self.arrayEntity setContent: tempArray];
    
    // Update the line if there are more than two entities

    [self updateView];
}

-(void)removeToken: (SpaceToken*) token{
    [token removeFromSuperview];

    // Depending on the token, different things need to be done
    if (token.spatialEntity == self.arrayEntity){
        // masterToken is removed
        self.arrayEntity = [[Route alloc] init];
        self.arrayEntity.name = [NSString stringWithFormat:@"SC-%d", counter++];
        self.arrayEntity.appearanceMode = SETMODE;
        self.masterToken = nil;
    }else{
        [self.arrayEntity removeObject:token.spatialEntity];
    }
    
    [self updateView];
}

-(void)removeMaster{
    if (self.masterToken){
        [self.masterToken removeFromSuperview];
        self.arrayEntity = [[Route alloc] init];
        self.arrayEntity.name = [NSString stringWithFormat:@"SC-%d", counter++];
        self.arrayEntity.appearanceMode = SETMODE;
        self.masterToken = nil;
    }
}

// MARK: button actions
- (IBAction)switchViewAction:(id)sender {
    if (self.setToolMode==EmptyMode || self.setToolMode == MapMode){
        self.setToolMode = SetMode;
    }else{
        self.setToolMode = MapMode;
    }
    [self updateView];
}

// MARK: view movement
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint touchPoint = [[touches anyObject] locationInView:self.toolView];
    
    if (CGRectContainsPoint(self.masterToken.frame, touchPoint)){
        moveMode = NO;
        return;
    }
    
    if (CGRectContainsPoint(self.bounds, touchPoint)){
        moveMode = YES;
    }else{
        moveMode = NO;
    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!moveMode)
        return;
    
    CGPoint currentPoint = [[touches anyObject] locationInView:self];
    CGPoint previousPoint = [[touches anyObject] previousLocationInView:self];
    CGPoint diff = CGPointMake(currentPoint.x - previousPoint.x, currentPoint.y - previousPoint.y);
    
    // Move the view
    self.toolView.center = CGPointMake(self.toolView.center.x + diff.x, self.toolView.center.y + diff.y);
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    moveMode = NO;
}

@end
