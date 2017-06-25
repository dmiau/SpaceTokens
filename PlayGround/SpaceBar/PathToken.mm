//
//  PathToken.m
//  SpaceBar
//
//  Created by dmiau on 11/16/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "PathToken.h"
#import "Route.h"
#import "SpaceToken+Tools.h"
#import "SpaceBar.h"
#import "Constants.h"

@implementation PathToken{
    NSMutableArray <SpaceToken*> *_tempChildrenTokenArray;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id) init{
    self = [super init];
    self.spatialEntity = [[Route alloc] init];
    _tempChildrenTokenArray = [NSMutableArray array];
    [self restoreDefaultStyle];
    return self;
}

- (void)restoreDefaultStyle{
    
    if (!self.spatialEntity ||
        ![self.spatialEntity isKindOfClass:[Route class]])
    {
        [self setBackgroundColor:[UIColor grayColor]];
    }else{
        [self setBackgroundColor:[UIColor grayColor]];
        UIImage *arrayIcon = [UIImage imageNamed:@"arrayIcon"];
        UIImage *pathIcon = [UIImage imageNamed:@"pathIcon"];
        UIImage *setIcon = [UIImage imageNamed:@"setIcon"];
        
        Route *aRoute = self.spatialEntity;
        switch (aRoute.appearanceMode) {
            case ARRAYMODE:
                
                [self setBackgroundImage:arrayIcon forState:UIControlStateNormal];
                break;
            case SETMODE:
                
                [self setBackgroundImage:setIcon forState:UIControlStateNormal];
                break;
            case ROUTEMODE:
                
                [self setBackgroundImage:pathIcon forState:UIControlStateNormal];
                break;
            case SKETCHEDROUTE:
                [self setBackgroundImage:pathIcon forState:UIControlStateNormal];
                break;
            default:
                break;
        }
    }
    
    //UIEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right);
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    if ([self.spatialEntity.name length] > 6){
        self.titleLabel.numberOfLines = 2;
    }
}

// MARK: Setters
- (void)setSpatialEntity:(SpatialEntity *)spatialEntity{
    [super setSpatialEntity:spatialEntity];
    
    if ([spatialEntity isKindOfClass:[Route class]]){
        Route *aRoute = spatialEntity;
        aRoute.appearanceChangedHandlingBlock = ^(){
            [self restoreDefaultStyle];
        };
    }
    [self restoreDefaultStyle];
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    
    if (self.spatialEntity.appearanceMode == SETMODE)
    {
        // Put the child tokens into touching set?
        if (selected){
            [self genTempChildrenTokenArray];
            [self addChildrenEntitiesToTouchingSet];
            
        }else{
            [self removeChildrenEntitiesFromTouchingSet];
        }
    }
}

-(void)genTempChildrenTokenArray{
    [self removeChildrenEntitiesFromTouchingSet];
    [_tempChildrenTokenArray removeAllObjects];
    for (SpatialEntity *entity in  [self.spatialEntity getContent]){
        SpaceToken *token = [SpaceToken manufactureTokenForEntity:entity];
        [_tempChildrenTokenArray addObject:token];
    }
}

-(void)addChildrenEntitiesToTouchingSet{
    for (SpaceToken *token in _tempChildrenTokenArray){
        NSNotification *notification = [NSNotification notificationWithName:AddToTouchingSetNotification
            object:token userInfo:nil];
        [[ NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

-(void)removeChildrenEntitiesFromTouchingSet{
    for (SpaceToken *token in _tempChildrenTokenArray){
        NSNotification *notification = [NSNotification notificationWithName:RemoveFromTouchingSetNotification
            object:token userInfo:nil];
        [[ NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

@end
