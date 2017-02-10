//
//  Area.h
//  SpaceBar
//
//  Created by Daniel on 12/30/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "LineEntity.h"
#import "CustomMKPolygon.h"
#import "CustomGMSPolyline.h"

@interface Area : LineEntity

@property CustomMKPolygon *polygon;
@property CustomGMSPolyline *annotation;
@end
