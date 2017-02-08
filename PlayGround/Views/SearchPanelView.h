//
//  SearchPanelView.h
//  SpaceBar
//
//  Created by dmiau on 9/28/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "topPanel.h"

@class POI;
@class GMSAutocompleteResultsViewController;
@class CustomSearchResultViewController;
@class SpaceToken;

@interface SearchPanelView : UIView <TopPanel, UISearchBarDelegate>{
    SpaceToken *renamedToken; // cache the token that is being renamed
}

@property ViewController *rootViewController;
@property UIButton *directionButton;

//---------------
// Search Bar related items
//---------------
@property (weak, nonatomic) IBOutlet UIView *searchPlaceHolder;

//@property GMSAutocompleteResultsViewController *resultsViewController;
@property CustomSearchResultViewController *resultsViewController;
@property UISearchController *searchController;
@property (nonatomic, copy) void (^searchHandlingBlock)(POI *destinationPOI);
@property (weak, nonatomic) IBOutlet UIButton *drawingButton;


//---------------
// Search Panel actions
//---------------

- (IBAction)prefAction:(id)sender;

- (IBAction)refreshAction:(id)sender;


- (IBAction)barToolAction:(id)sender;
- (IBAction)areaToolAction:(id)sender;

- (IBAction)dataAction:(id)sender;
- (IBAction)speechAction:(id)sender;


@end
