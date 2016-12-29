//
//  NSValue+MKMapPoint.m
//  SpaceBar
//
//  Created by Daniel on 12/28/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "NSValue+MKMapPoint.h"

//http://stackoverflow.com/questions/32454230/convert-mkmappoint-to-nsvalue-in-swift

@implementation NSValue (MKMapPoint)
+ (NSValue *)valueWithMKMapPoint:(MKMapPoint)mapPoint {
    return [NSValue value:&mapPoint withObjCType:@encode(MKMapPoint)];
}

- (MKMapPoint)MKMapPointValue {
    MKMapPoint mapPoint;
    [self getValue:&mapPoint];
    return mapPoint;
}
@end
