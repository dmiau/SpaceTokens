//
//  ViewController.m
//  PlayGround
//
//  Created by dmiau on 1/28/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "tester.h"
#import "Map/Route.h"
#import "Map/RouteDatabase.h"
#import "EntityDatabase.h"
#import "Map/MiniMapView.h"
#import "StudyManager/GameManager.h"
#import "StudyManager/SnapshotDatabase.h"
#import "SpeechEngine.h"


#import "TokenCollectionView.h"
#import "MapInformationSheet.h"
#import "ArrayTool.h"

// This is an extension (similar to a category)
@interface ViewController ()

@property NSNumber *touchFlag;

@end


//-------------------
// Parameters
//-------------------
#define topPanelHeight 120
#define bottomPanalHeight 40
#define CELL_WIDTH 60
#define CELL_HEIGHT 30

//-------------------
// ViewController
//-------------------
@implementation ViewController

static ViewController *instance;

+ (ViewController*)sharedManager { return instance; }

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self){
        instance = self;
        self.isStatusBarHidden = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    //----------------
    // Initialize File Manager
    //----------------
    self.myFileManager = [MyFileManager sharedManager];
    self.myFileManager.directorPartialPath = @"test";
    
    //----------------
    // Initialize a Route DB
    //----------------
    self.routeDatabase = [RouteDatabase sharedManager];
    [self.routeDatabase reloadRouteDB];    
    
    //----------------
    // Initialize an Entity DB
    //----------------
    self.entityDatabase = [EntityDatabase sharedManager];
    [self.entityDatabase debugInit];
    
    //----------------
    // Initialize a Snapshot DB
    //----------------
    SnapshotDatabase *mySnapshotDatabase = [SnapshotDatabase sharedManager];
    mySnapshotDatabase.name = @"Study";
    [mySnapshotDatabase debugInit];
    
    //----------------
    // Initialize Study Manager
    //----------------
    self.gameManager = [GameManager sharedManager];
    
    //----------------
    // Add a mapView
    //----------------
    self.mapView = [CustomMKMapView sharedManager];
    self.mapView.frame = CGRectMake(0, topPanelHeight,
                                    self.view.frame.size.width,
                                    self.view.frame.size.height - topPanelHeight - bottomPanalHeight);
    [self.view addSubview:self.mapView];
    [self.mapView setUserInteractionEnabled:YES];
    MKCoordinateRegion initRegion = MKCoordinateRegionMake(
    CLLocationCoordinate2DMake(40.761040, -73.977778),
    MKCoordinateSpanMake(0.171841, 0.164558));
    [self.mapView setRegion:initRegion];
    
    self.mapView.delegate = self;
    self.mapView.settings.compassButton = true;
    
    //----------------
    // Add a mini map
    //----------------
    self.miniMapView = [[MiniMapView alloc] initWithFrame:
                        CGRectMake(50, self.mapView.frame.size.height-130,
                                   130, 130)];
    [self.miniMapView setUserInteractionEnabled:YES];
    self.miniMapView.settings.compassButton = false;
    
    //----------------
    // Add a SpaceBar
    //----------------
    _spaceBar = [[SpaceBar alloc] initWithMapView:_mapView];
    self.spaceBar.spaceBarMode = TOKENONLY;
    self.spaceBar.smallValueOnTopOfBar = YES;
    self.spaceBar.delegate = self;
    
    //----------------
    // Initialize MainViewManager
    //----------------
    self.mainViewManager = [[MainViewManager alloc] initWithViewController:self];
    
//    // Run the test
//    Tester *tester = [[Tester alloc] init];
//    [tester runTests];
    
    //----------------
    // Initialize SpeechRecognizer
    //----------------
    self.speechEngine = [[SpeechEngine alloc] init];    
}

- (void)setIsStatusBarHidden:(BOOL)isStatusBarHidden{
    _isStatusBarHidden = isStatusBarHidden;
    [self setNeedsStatusBarAppearanceUpdate];
}


- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
    
    SpaceBar *spaceBar = [SpaceBar sharedManager];
    [spaceBar resetInteractiveTokenStructures];
    
    // Clear all annotations
    [self.mapView clear];
    
    // Do a forced refresh if the tokenView is enabled
    TokenCollectionView *tokenCollectionView = [TokenCollectionView sharedManager];
    if (tokenCollectionView.isVisible)
        [tokenCollectionView reloadData];
    
    // TopPanel viewWillAppaer
    [self.mainViewManager.activePanel viewWillAppear:NO];    
}

// Update the placement of GUI elements
- (void)updateUIPlacement{
    
    // Get the specification of the information sheet
    MapInformationSheet *informationSheet = self.mapView.informationSheet;
    
    //----------------------
    // Update the placement of TokenCollectionView
    //----------------------
    TokenCollectionView *tokenCollectionView = [TokenCollectionView sharedManager];
    
    //UIEdgeInsets UIEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right);
    UIEdgeInsets tokenCollectionViewInsets = tokenCollectionView.layoutMargins;
    CGRect newFrame= self.mapView.frame;
    if (informationSheet.superview){
        // The map information sheet is visible
        newFrame.size.height = informationSheet.frame.origin.y -
                               self.mapView.frame.origin.y;
    }else{
//        tokenCollectionViewInsets = UIEdgeInsetsMake(30, self.mapView.frame.size.width- CELL_WIDTH, 0, 0);
    }
    
    [tokenCollectionView updateFrame:newFrame andEdgeInsets:tokenCollectionViewInsets];
    
    //----------------------
    // Update the placement of ArrayTool
    //----------------------
    [[ArrayTool sharedManager] setFrame:newFrame];
}


- (void)viewDidDisappear:(BOOL)animated{

}

- (BOOL)prefersStatusBarHidden {
    return self.isStatusBarHidden;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
