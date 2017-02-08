//
//  CustomSearchResultViewController.m
//  SpaceBar
//
//  Created by dmiau on 2/8/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "CustomSearchResultViewController.h"

NSString *const kCellIdentifier = @"cellID";
NSString *const kTableCellNibName = @"SearchResultTableCell";

@interface CustomSearchResultViewController ()<GMSAutocompleteFetcherDelegate>

@end

@implementation CustomSearchResultViewController{
    NSMutableArray <GMSAutocompletePrediction*> *_predictionArray;
    GMSAutocompleteFetcher* _fetcher;
    NSString *_searchText;
}

// MARK: Init

-(id)init{
    self = [super init];
    
    //-----------------
    // Register the custom cell
    //-----------------
    [self.tableView registerNib:[UINib nibWithNibName:kTableCellNibName bundle:nil] forCellReuseIdentifier:kCellIdentifier];
    
    // Set up the autocomplete filter.
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    filter.type = kGMSPlacesAutocompleteTypeFilterEstablishment;
    
    // Set bounds to NY.
    CLLocationCoordinate2D neBoundsCorner = CLLocationCoordinate2DMake(40.825615, -74.027252);
    CLLocationCoordinate2D swBoundsCorner = CLLocationCoordinate2DMake(40.695070, -73.925629);
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:neBoundsCorner
        coordinate:swBoundsCorner];
    
    // Create the fetcher.
    _fetcher = [[GMSAutocompleteFetcher alloc] initWithBounds:bounds
                                                       filter:filter];
    _fetcher.delegate = self;
    
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _predictionArray = [NSMutableArray array];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setDelegate:(id<CustomSearchResultViewControllerDelegate>)delegate{
    _delegate = delegate;
    if (_delegate != delegate){
        _delegateRespondsTo.didAutocompleteWithPlaces =
        [_delegate respondsToSelector:@selector(didAutocompleteWithPlaces:)];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 0){
        return 1;
    }else{
        return [_predictionArray count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = [indexPath section];
    int row = [indexPath row];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    if (section == 0){
        cell.textLabel.text = _searchText;
        cell.detailTextLabel.text = @"show all results";
    }else{
        GMSAutocompletePrediction* prediction = _predictionArray[row];
        // Highlight certain characters
        UIFont *regularFont = [UIFont systemFontOfSize:[UIFont labelFontSize]];
        UIFont *boldFont = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
        
        NSMutableAttributedString *bolded = [prediction.attributedPrimaryText mutableCopy];
        [bolded enumerateAttribute:kGMSAutocompleteMatchAttribute
                           inRange:NSMakeRange(0, bolded.length)
                           options:0
                        usingBlock:^(id value, NSRange range, BOOL *stop) {
                            UIFont *font = (value == nil) ? regularFont : boldFont;
                            [bolded addAttribute:NSFontAttributeName value:font range:range];
                        }];
        
        // Configure the cell...
        cell.textLabel.attributedText = bolded;
        cell.detailTextLabel.text = prediction.attributedSecondaryText.string;
    }
    return cell;
}

#pragma mark -----Table Interaction Methods-----
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)path {
    int section_id = [path section];
    int row_id = [path row];
    
    if (section_id == 0){
        int expectedResultCount = [_predictionArray count];
        NSMutableArray *placeResultArray = [NSMutableArray array];
        for (GMSAutocompletePrediction *prediction in _predictionArray){
            //Need to issue location lookup request
            [[GMSPlacesClient sharedClient] lookUpPlaceID:prediction.placeID callback:
             ^(GMSPlace *place, NSError *error){
                 [placeResultArray addObject:place];
                 if ([placeResultArray count] == expectedResultCount){
                     [self sendDelegatePlaces:placeResultArray];
                 }
             }];
        }    
    }else{
        // Get the placeID
        GMSAutocompletePrediction *prediction = _predictionArray[row_id];
        //Need to issue location lookup request
        [[GMSPlacesClient sharedClient] lookUpPlaceID:prediction.placeID callback:
         ^(GMSPlace *place, NSError *error){
             NSMutableArray *placeResultArray = [NSMutableArray array];
             [placeResultArray addObject:place];
             [self sendDelegatePlaces:placeResultArray];
         }];
    }
}

-(void)sendDelegatePlaces:(NSArray*)placeArray{
    [self.delegate didAutocompleteWithPlaces:placeArray];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    // update the filtered array based on the search text
    _searchText = searchController.searchBar.text;
    
    [_fetcher sourceTextHasChanged:_searchText];
}

#pragma mark - GMSAutocompleteFetcherDelegate
- (void)didAutocompleteWithPredictions:(NSArray *)predictions {
    _predictionArray = predictions;
    
    [self.tableView reloadData];
}

- (void)didFailAutocompleteWithError:(NSError *)error {
//    _resultText.text = [NSString stringWithFormat:@"%@", error.localizedDescription];
}

@end
