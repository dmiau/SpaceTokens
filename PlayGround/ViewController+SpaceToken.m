//
//  ViewController+SpaceToken.m
//  SpaceBar
//
//  Created by Daniel on 9/3/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "ViewController+SpaceToken.h"

@implementation ViewController (SpaceToken)

- (void)refreshSpaceTokens{
    // Remove all the SpaceTokens
    [self.spaceBar removeAllSpaceTokens];
    [self.spaceBar
     addSpaceTokensFromPOIArray: self.spaceBar.poiArrayDataSource];
    self.spaceBar.spaceBarMode = TOKENONLY;
}
@end
