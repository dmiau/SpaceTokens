//
//  SearchPanelView.h
//  SpaceBar
//
//  Created by dmiau on 9/28/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "topPanel.h"
@import GoogleMaps;
@import GooglePlaces;
#import <GoogleMaps/GoogleMaps.h>

@interface SearchPanelView : UIView <TopPanel>

@property ViewController *rootViewController;
@property UIButton *directionButton;

//---------------
// Search Bar related items
//---------------
@property (weak, nonatomic) IBOutlet UIView *searchPlaceHolder;

@property GMSAutocompleteResultsViewController *resultsViewController;
@property UISearchController *searchController;






//---------------
// Search Panel actions
//---------------


- (IBAction)prefAction:(id)sender;

- (IBAction)barToolAction:(id)sender;
- (IBAction)areaToolAction:(id)sender;




- (IBAction)dataAction:(id)sender;
- (IBAction)speechAction:(id)sender;


@end
