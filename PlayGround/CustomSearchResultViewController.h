//
//  CustomSearchResultViewController.h
//  SpaceBar
//
//  Created by dmiau on 2/8/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>

// MARK: Delegate
@protocol CustomSearchResultViewControllerDelegate <NSObject>
-(void)didAutocompleteWithPlaces:(NSArray <GMSPlace*> *)places;
@end


// MARK: Interface
@interface CustomSearchResultViewController : UITableViewController<UISearchControllerDelegate, UISearchResultsUpdating>

@property  struct {
unsigned int didAutocompleteWithPlaces:1;
} delegateRespondsTo;

@property (nonatomic, weak) id <CustomSearchResultViewControllerDelegate> delegate;
@property GMSCoordinateBounds *autocompleteBounds;


@end
