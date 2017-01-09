//
//  SetTool.m
//  SpaceBar
//
//  Created by Daniel on 1/9/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "SetTool.h"
#import "CustomMKMapView.h"
#import "MiniMapView.h"
#import "ArrayEntity.h"
#import "SpaceToken.h"
#import "TokenCollection.h"
#import "Constants.h"
#import "ViewController.h"

//-------------------
// Parameters
//-------------------
#define TOOL_WIDTH 150
#define TOOL_HEIGHT 150

@implementation SetTool{
    SpaceToken *masterToken;
    BOOL moveMode;
    UIView *toolView;
}

// MARK: Initialization
+(id)sharedManager{
    static SetTool *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SetTool alloc] init];
    });
    
    
    return sharedInstance;
}

- (id) init{

    self = [super init];
    
    //----------------
    // Initialize properties
    //----------------
    _isVisible = NO;
    masterToken = nil;
    moveMode = NO; //
    self.arrayEntity = [[ArrayEntity alloc] init];
    
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    self.frame = mapView.frame;
    
    //----------------
    // Add a toolView
    //----------------
    CGRect defaultFrame = CGRectMake(70, mapView.frame.size.height - TOOL_HEIGHT, TOOL_WIDTH, TOOL_HEIGHT);
    toolView = [[UIView alloc] initWithFrame:defaultFrame];
    [toolView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.2]];
    [self addSubview:toolView];
    
    //----------------
    // Add a mini map
    //----------------
    self.miniMapView = [[MiniMapView alloc] initWithFrame:
                        CGRectMake(0, 30, TOOL_WIDTH, TOOL_HEIGHT)];
    [self.miniMapView setUserInteractionEnabled:NO];
    self.miniMapView.showsCompass = NO;
    
    [toolView addSubview:self.miniMapView];
    // Make the mini map hidden by default
    [self.miniMapView setHidden:YES];
    
    // listen to the map change event
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(updateBoxInMiniMap)
                   name:MapUpdatedNotification
                 object:nil];
    
    return self;
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
    [toolView addSubview:masterToken];
}

-(void)updateView{
    // Create an entity set
    NSSet *entitySet = [NSSet setWithArray:self.arrayEntity.contentArray];
    
    if ([self.arrayEntity.contentArray count]==1
        && !masterToken)
    {
        // Insert a master token on the top
        [self initMasterToken];
    }
    
    if ([self.arrayEntity.contentArray count] >= 1){
        // MiniMap should be visible
        // Make the miniMap visible if it is not visible already
        if (self.miniMapView.isHidden){
            [self.miniMapView setHidden:NO];
        }
        // refresh the map
        [self.miniMapView zoomToFitEntities: entitySet];
        
        // Update the bound of the master token
        [self.arrayEntity updateBoundingMapRect];
    }else{
        // MiniMap should be invisible
        // Make the miniMap visible if it is not visible already
        if (!self.miniMapView.isHidden){
            [self.miniMapView setHidden:YES];
        }
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

// MARK: hit tests
-(BOOL)isTouchInInsertionZone:(UITouch*)touch{
    if (!self.isVisible)
        return NO;
    
    CGPoint touchPoint = [touch locationInView:toolView];
    
    if (CGRectContainsPoint(CGRectMake(0, 30, TOOL_WIDTH, TOOL_HEIGHT - 30), touchPoint)){
        return YES;
    }else{
        return NO;
    }
}

-(BOOL)isTouchInMasterTokenZone:(UITouch*)touch{
    if (!self.isVisible)
        return NO;
    
    CGPoint touchPoint = [touch locationInView:toolView];
    
    if (CGRectContainsPoint(CGRectMake(0, 0, 60, 30), touchPoint)){
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // UIView will be "transparent" for touch events if we return NO
    return (CGRectContainsPoint(toolView.frame, point));
}

// MARK: Token management
-(void)insertMaster:(SpaceToken*) token{
    
    // Remove the current master
    if (masterToken){
        [masterToken removeFromSuperview];
        [[TokenCollection sharedManager] removeToken:masterToken];
    }
    
    TokenCollection *tokenCollection = [TokenCollection sharedManager];
    masterToken = [tokenCollection addTokenFromSpatialEntity:token.spatialEntity];
    masterToken.home = self;
    
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(60, 20);
    [toolView addSubview:masterToken];
    
    self.arrayEntity = masterToken.spatialEntity;
    [self updateView];
}

-(void) insertToken: (SpaceToken*) token{
    // Create a new SpaceToken based on anchor
    [self.arrayEntity.contentArray addObject:token.spatialEntity];
    [self updateView];
}

-(void)removeToken: (SpaceToken*) token{
    [token removeFromSuperview];
    [[TokenCollection sharedManager] removeToken:token];
    // Depending on the token, different things need to be done
    if (token.spatialEntity == self.arrayEntity){
        // masterToken is removed
        self.arrayEntity = [[ArrayEntity alloc] init];
        masterToken = nil;
    }else{
        [self.arrayEntity.contentArray removeObject:token.spatialEntity];
    }
    
    [self updateView];
}

// MARK: view movement



-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint touchPoint = [[touches anyObject] locationInView:toolView];
    
    CGRect moveDetectionArea = CGRectMake(60, 0, 90, 30);
    if (CGRectContainsPoint(moveDetectionArea, touchPoint)){
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
    toolView.center = CGPointMake(toolView.center.x + diff.x, toolView.center.y + diff.y);
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    moveMode = NO;
}

@end
