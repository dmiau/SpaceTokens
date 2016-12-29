//
//  NSValue+MKMapPoint.h
//  SpaceBar
//
//  Created by Daniel on 12/28/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface NSValue (MKMapPoint)
+ (NSValue *)valueWithMKMapPoint:(MKMapPoint)mapPoint;
- (MKMapPoint)MKMapPointValue;
@end
