//
//  CollectionInformationSheet.m
//  SpaceBar
//
//  Created by dmiau on 2/9/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "CollectionInformationSheet.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+tools.h"
#import "EntityDatabase.h"
#import "Route.h"


#define INITIAL_HEIGHT 80
@implementation CollectionInformationSheet

-(void)awakeFromNib{
    [super awakeFromNib];
    
    // Initialize the object
    self.titleOutlet.delegate = self;
    
    [self.starOutlet setTitle:@"remove" forState:UIControlStateNormal];
}

// MARK: Setters
//-------------------------------------
-(void)setSpatialEntity:(SpatialEntity *)spatialEntity{
    
    // Remove the previous observer
    if (self.spatialEntity){
        [self.spatialEntity removeObserver:self forKeyPath:@"dirtyFlag"];
    }
    
    [super setSpatialEntity:spatialEntity];
    
    // Add a new observer
    [spatialEntity addObserver:self forKeyPath:@"dirtyFlag" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                       context:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if([keyPath isEqualToString:@"dirtyFlag"] && object == self.spatialEntity)
    {
        [self updateSheet];
    }
}


-(void)addSheetForEntity:(SpatialEntity*)entity{
    [super addSheetForEntity:entity];
    [self.starOutlet setTitle:@"remove" forState:UIControlStateNormal];
}

-(void)updateSheet{        
    self.titleOutlet.text = self.spatialEntity.name;

    self.detailTextView.text = self.spatialEntity.description;
    
    if ([self.spatialEntity isKindOfClass:[Route class]]){
        Route *aRoute = self.spatialEntity;
        self.quickInfoOutlet.text = [NSString stringWithFormat:@"%.2f mins, %.0f (m)",
                                     aRoute.expectedTravelTime/60, aRoute.distance];
        
        self.collectionModeOutlet.selectedSegmentIndex = aRoute.appearanceMode;
    }else{
        self.quickInfoOutlet.text = @"";
    }
    
    if ([self.spatialEntity isMemberOfClass:[Route class]]){
        Route *aRoute = self.spatialEntity;
        if (aRoute.appearanceMode == ROUTEMODE &&
            !aRoute.isMapAnnotationEnabled)
        {
            // Don't show the sheet if the entity is invisible
            [self removeSheet];
        }
    }
}

// MARK: Setters
//-------------------------------------
//-(void)setSpatialEntity:(SpatialEntity *)spatialEntity{
//    _spatialEntity = spatialEntity;
//    self.titleOutlet.text = spatialEntity.name;
//}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //---------------
    // Rename a token
    //---------------
    self.spatialEntity.name = self.titleOutlet.text;
    
    // Find all the tokens with the same spatial entity
    for (SpaceToken *token in [[TokenCollection sharedManager] getTokenArray]){
        if (token.spatialEntity == self.spatialEntity){
            [token
             setTitle: self.titleOutlet.text
             forState: UIControlStateNormal];
        }
    }
    
    [self.titleOutlet resignFirstResponder];
    
    // Need to shift the panel down
    CGRect superFrame = self.superview.frame;
    CGRect frame = CGRectMake(0, superFrame.size.height - INITIAL_HEIGHT,
                              self.frame.size.width, self.frame.size.height);
    self.frame = frame;
    
    return YES;
}

// MARK: Button actions
- (IBAction)starAction:(id)sender {
    SpatialEntity *entity = self.spatialEntity;
    if ([self.starOutlet.titleLabel.text isEqualToString: @"remove"]){
        
        // Find the tokens associated with the entity
        
        
        
        [[EntityDatabase sharedManager] removeEntity:entity];
        [self.starOutlet setTitle:@"save" forState:UIControlStateNormal];
        [self removeSheet];
    }else{
        [[EntityDatabase sharedManager] addEntity:entity];
        [self.starOutlet setTitle:@"remove" forState:UIControlStateNormal];
    }

    [self updateSheet];
}

- (IBAction)collectionModeAction:(id)sender {
    if (![self.spatialEntity isKindOfClass:[Route class]])
        return;
    
    Route *aRoute = self.spatialEntity;
    
    aRoute.appearanceMode = (AppeararnceMode)self.collectionModeOutlet.selectedSegmentIndex;
    aRoute.isMapAnnotationEnabled = YES;
    
    if (aRoute.appearanceMode == ROUTEMODE){
        // A user might turn a tempRoute object into a route
        [[EntityDatabase sharedManager] addEntity:aRoute];
    }
}


@end
