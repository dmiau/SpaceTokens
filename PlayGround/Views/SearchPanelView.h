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
@class SpaceToken;

@interface SearchPanelView : UIView <TopPanel>{
    SpaceToken *renamedToken; // cache the token that is being renamed
}

@property ViewController *rootViewController;
@property UIButton *directionButton;

//---------------
// Search Bar related items
//---------------
@property (weak, nonatomic) IBOutlet UIView *searchPlaceHolder;

@property GMSAutocompleteResultsViewController *resultsViewController;
@property UISearchController *searchController;
@property (nonatomic, copy) void (^searchHandlingBlock)(POI *destinationPOI);
@property (weak, nonatomic) IBOutlet UIButton *drawingButton;

@property (weak, nonatomic) IBOutlet UITextField *renamingOutlet;


//---------------
// Search Panel actions
//---------------
- (IBAction)renamingAction:(id)sender;

- (IBAction)prefAction:(id)sender;

- (IBAction)barToolAction:(id)sender;
- (IBAction)areaToolAction:(id)sender;

- (IBAction)dataAction:(id)sender;
- (IBAction)speechAction:(id)sender;


@end
