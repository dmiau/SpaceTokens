//
//  TouchableStructureProtocol.h
//  SpaceBar
//
//  Created by Daniel on 1/23/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SpaceToken;

@protocol TouchableStructureProtocol <NSObject>

-(void(^)(SpaceToken*))touchesInsertionZone: (UITouch*)touch;

@end
