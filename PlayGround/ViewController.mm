//
//  ViewController.m
//  PlayGround
//
//  Created by dmiau on 1/28/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "ViewController.h"
#import "tester.h"
#import "Views/DirectionPanel.h"
#import "Views/DefaultSearchPanel.h"
#import "Map/Route.h"
#import "Map/POIDatabase.h"

//-------------------
// Parameters
//-------------------
#define topPanelHeight 120


// This is an extension (similar to a category)
@interface ViewController ()

@property NSNumber *touchFlag;

@end


//-------------------
// ViewController
//-------------------
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    //----------------
    // Initialize a POI DB
    //----------------
    self.poiDatabase = [[POIDatabase alloc] init];
    [self.poiDatabase reloadPOI];
    
    //----------------
    // Add a mapView
    //----------------
    self.mapView = [[customMKMapView alloc] initWithFrame:CGRectMake(0, topPanelHeight,
                    self.view.frame.size.width, self.view.frame.size.height - topPanelHeight)];
    [self.view addSubview:self.mapView];
    [self.mapView setUserInteractionEnabled:YES];
    
    self.mapView.delegate = self;
    
//    [self.mapView setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 60)];
    self.mapView.showsCompass = NO;
//    self.mapView.mapType = MKMapTypeSatelliteFlyover;
    
    //----------------
    // Add a SpaceBar
    //----------------
    _spaceBar = [[SpaceBar alloc] initWithMapView:_mapView];
    [self.spaceBar.sliderContainer setUserInteractionEnabled: NO];
    self.spaceBar.smallValueOnTopOfBar = false;
    self.spaceBar.delegate = self;
    
    //----------------
    // Add a search panel
    //----------------
    [self addDefaultSearchPanel];
    
    //------------------
    // Add a direction button for testing
    //------------------
    
    float mapViewWidth = self.mapView.frame.size.width;
    float mapViewHeight = self.mapView.frame.size.height;
    UIButton*  directionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    directionButton.frame = CGRectMake(mapViewWidth*0.1, mapViewHeight*0.9, 60, 20);
    [directionButton setTitle:@"Direction" forState:UIControlStateNormal];
    directionButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [directionButton setBackgroundColor:[UIColor grayColor]];
    [directionButton addTarget:self action:@selector(directionButtonAction)
              forControlEvents:UIControlEventTouchDown];
    
    // add drop shadow
    //            self.layer.cornerRadius = 8.0f;
    directionButton.layer.masksToBounds = NO;
    //            self.layer.borderWidth = 1.0f;
    
    directionButton.layer.shadowColor = [UIColor grayColor].CGColor;
    directionButton.layer.shadowOpacity = 0.8;
    directionButton.layer.shadowRadius = 12;
    directionButton.layer.shadowOffset = CGSizeMake(12.0f, 12.0f);
    
    
    
    [self.mapView addSubview:directionButton];

//    // Run the test
//    Tester *tester = [[Tester alloc] init];
//    [tester runTests];
}

- (void)addDirectionPanel{
    
    if (self.directionPanel){
        // add the panel to the main view if it has been instantiated
        [self.view addSubview:self.directionPanel];
    }else{
        self.directionPanel = [[DirectionPanel alloc] initWithFrame:
                CGRectMake(0, 0, self.view.frame.size.width, topPanelHeight)];
        [self.view addSubview:self.directionPanel];
    }
    
    // remove all
    [self.spaceBar removeAllSpaceTokens];
    [self.spaceBar.sliderContainer setUserInteractionEnabled: YES];
}

- (void)addDefaultSearchPanel{
    
    if (!self.defaultSearchPanel){
        self.defaultSearchPanel = [[DefaultSearchPanel alloc]
                                   initWithFrame:
    CGRectMake(0, 0, self.view.frame.size.width, topPanelHeight)];
    }
    
    [self.view addSubview:self.defaultSearchPanel];
    
    [self initSpaceBarWithTokens];
}

- (void) initSpaceBarWithTokens{

    // Add SpaceTokens
    [self.spaceBar addSpaceTokensFromPOIArray: self.poiDatabase.poiArray];
    [self.spaceBar.sliderContainer setUserInteractionEnabled: NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
