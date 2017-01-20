//
//  PathToken.m
//  SpaceBar
//
//  Created by dmiau on 11/16/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "PathToken.h"
#import "Route.h"

@implementation PathToken

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
    [self restoreDefaultStyle];
    return self;
}

- (void)restoreDefaultStyle{
    
    if (!self.spatialEntity ||
        ![self.spatialEntity isKindOfClass:[Route class]])
    {
        [self setBackgroundColor:[UIColor orangeColor]];
    }else{
//        if (![self.spatialEntity isKindOfClass:[Route class]]){
//            [NSException raise:@"Programming error." format:@"PathToken's spatialEntity should be of the Route type."];
//        }
        
        Route *aRoute = self.spatialEntity;
        switch (aRoute.appearanceMode) {
            case ARRAYMODE:
                [self setBackgroundColor:[UIColor purpleColor]];
                break;
            case SETMODE:
                [self setBackgroundColor:[UIColor brownColor]];
                break;
            case ROUTEMODE:
                [self setBackgroundColor:[UIColor orangeColor]];
                break;
            default:
                break;
        }
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
@end
