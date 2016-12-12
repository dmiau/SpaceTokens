//
//  CollectionViewCell.m
//  lab_CollectionView
//
//  Created by dmiau on 12/5/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "CollectionViewCell.h"
#import "EntityDatabase.h"
#import "TokenCollection.h"
#import "POI.h"
#import "Route.h"
#import "Person.h"
#import "SpaceToken.h"
#import "PathToken.h"

@implementation CollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor greenColor];
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowRadius = 3.0f;
        self.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
        self.layer.shadowOpacity = 0.3f;
        
        // Selected background view
        UIView *backgroundView = [[UIView alloc]initWithFrame:self.bounds];
        backgroundView.layer.borderColor = [[UIColor colorWithRed:0.529 green:0.808 blue:0.922 alpha:1]CGColor];
        backgroundView.layer.borderWidth = 10.0f;
        self.selectedBackgroundView = backgroundView;
        
    }
    return self;
}



- (void)configureSpaceTokenFromEntity:(SpatialEntity *)spatialEntity{
    
    // Depending on the type of spatialEntity, instantiate a corresponding spaceToken
    SpaceToken *aSpaceToken;
    if ([spatialEntity isKindOfClass:[POI class]] ||
        [spatialEntity isKindOfClass:[Person class]]){
        aSpaceToken = [[SpaceToken alloc] init];
    }else if ([spatialEntity isKindOfClass:[Route class]]){
        aSpaceToken = [[PathToken alloc] init];
    }else{
        // error
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SpaceToken Error"
                                                        message:@"Unimplemented code path."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert show];
    }
    
    [aSpaceToken configureAppearanceForType:DOCKED];
    
    [aSpaceToken setTitle:spatialEntity.name forState:UIControlStateNormal];
    aSpaceToken.spatialEntity = spatialEntity;
    spatialEntity.linkedObj = aSpaceToken; // Establish the connection
    
    
    if (aSpaceToken){
        // Add to the cell
        
        if (self.spaceToken){
            [self.spaceToken removeFromSuperview];
            self.spaceToken = nil; // destroy the current SpaceToken
        }
        
        self.spaceToken = aSpaceToken;
        [self addSubview:aSpaceToken];
        [[TokenCollection sharedManager].tokenArray
         addObject:aSpaceToken];
        spatialEntity.isMapAnnotationEnabled = YES;
    }else{
        // error
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SpaceToken Error"
                                                        message:@"Cannot add new SpaceToken."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert show];
    }
}

@end
