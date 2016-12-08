//
//  TokenCollection.h
//  SpaceBar
//
//  Created by dmiau on 11/20/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SpaceBar; // Forward declaration
@class SpaceToken;


//---------------------------
// TokenCollection is a convenient structure which holds
// references to all the SpaceTokens on the dock
//---------------------------
@interface TokenCollection : NSObject

+ (TokenCollection*)sharedManager;

@property NSMutableArray <SpaceToken*> *tokenArray;

@end
