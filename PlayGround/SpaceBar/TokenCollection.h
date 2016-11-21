//
//  TokenCollection.h
//  SpaceBar
//
//  Created by dmiau on 11/20/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpaceBar.h"

@interface TokenCollection : NSObject

+ (TokenCollection*)sharedManager;

@property NSMutableArray <SpaceToken*> *tokenArray;

@end
