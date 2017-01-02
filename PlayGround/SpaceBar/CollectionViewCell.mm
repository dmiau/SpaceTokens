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
        
        self.backgroundColor = [UIColor clearColor];
//        self.layer.shadowColor = [UIColor blackColor].CGColor;
//        self.layer.shadowRadius = 3.0f;
//        self.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
//        self.layer.shadowOpacity = 0.3f;
        
        // Selected background view
        UIView *backgroundView = [[UIView alloc]initWithFrame:self.bounds];
        backgroundView.layer.borderColor = [[UIColor colorWithRed:0.529 green:0.808 blue:0.922 alpha:1]CGColor];
        backgroundView.layer.borderWidth = 10.0f;
        self.selectedBackgroundView = backgroundView;
        
    }
    return self;
}

- (void)configureSpaceTokenFromEntity:(SpatialEntity *)spatialEntity{
    
    TokenCollection *tokenCollection = [TokenCollection sharedManager];
    SpaceToken* aToken = [tokenCollection findSpaceTokenFromEntity:spatialEntity];
    
    if (!aToken){
        aToken = [tokenCollection addTokenFromSpatialEntity:spatialEntity];
    }
    
    if (aToken != self.spaceToken){
        [self.spaceToken removeFromSuperview];
        self.spaceToken = aToken;
        [self addSubview:aToken];        
    }
    spatialEntity.isMapAnnotationEnabled = YES;
}

@end
