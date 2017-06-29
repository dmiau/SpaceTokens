//
//  InformationSheetManager.m
//  NavTools
//
//  Created by dmiau on 2/9/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "InformationSheetManager.h"
#import "MapInformationSheet.h"
#import "PointInformationSheet.h"
#import "CollectionInformationSheet.h"
#import "SpatialEntity.h"
#import "ArrayEntity.h"

@implementation InformationSheetManager{
    PointInformationSheet *_pointInformationSheet;
    CollectionInformationSheet *_collectionInformationSheet;
}

- (id)init{
    self = [super init];
    
    // Load the information sheet
    _pointInformationSheet = [[[NSBundle mainBundle] loadNibNamed:@"PointInformationSheet" owner:self options:nil] firstObject];
    
    _collectionInformationSheet = [[[NSBundle mainBundle] loadNibNamed:@"CollectionInformationSheet" owner:self options:nil] firstObject];
    
    self.activeSheet = _pointInformationSheet;
    return self;
}

-(void)addSheetForEntity:(SpatialEntity*)entity{    
    [self removeSheet];
    
    if ([entity isKindOfClass:[ArrayEntity class]]){
        self.activeSheet = _collectionInformationSheet;
    }else{
        self.activeSheet = _pointInformationSheet;
    }
    [self.activeSheet addSheetForEntity:entity];
}

-(void)removeSheet{
    [self.activeSheet removeSheet];
}

@end
