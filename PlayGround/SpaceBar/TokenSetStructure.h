//
//  TokenSetStructure.h
//  SpaceBar
//
//  Created by Daniel on 12/14/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>


@class SpaceToken;

@interface TokenSetStructure : NSObject

@property NSMutableSet <SpaceToken*> *set;

- (void)addToken: (SpaceToken*)aToken;
- (void)removeToken: (SpaceToken*)aToken;
- (void)removeAllTokens;

@end
