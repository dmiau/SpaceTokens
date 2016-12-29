//
//  UIBezierPath+Points.h
//  SpaceBar
//
//  Created by Daniel on 12/28/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>

// https://github.com/erica/iOS-6-Advanced-Cookbook/blob/master/C04%20-%20Geometry/01%20-%20Retrieving%20Points/UIBezierPath-Points.h

@interface UIBezierPath (Points)
@property (nonatomic, readonly) NSArray *points;
@property (nonatomic, readonly) NSArray *bezierElements;
@property (nonatomic, readonly) CGFloat length;

- (NSArray *) pointPercentArray;
- (CGPoint) pointAtPercent: (CGFloat) percent withSlope: (CGPoint *) slope;
+ (UIBezierPath *) pathWithPoints: (NSArray *) points;
+ (UIBezierPath *) pathWithElements: (NSArray *) elements;
@end
