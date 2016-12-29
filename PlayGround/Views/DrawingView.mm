//
//  DrawingView.m
//  SpaceBar
//
//  Created by Daniel on 12/28/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "DrawingView.h"
#import "UIBezierPath+Points.h"
#import "CustomMKMapView.h"
#import "NSValue+MKMapPoint.h"
#import "Route.h"
#import "EntityDatabase.h"
#import "TokenCollectionView.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM () == UIUserInterfaceIdiomPad)

@implementation DrawingView

-(id)init{
    self = [super init];
    if (self){
        [self setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.2]];
    }
    return self;
}

-(void)viewWillAppear{
    // Initialize a new path for the user gesture
    path = [UIBezierPath bezierPath];
}

-(void)viewWillDisappear{
    // Bake the path to the map
    NSArray *pointArray = [path points];
    
    if ([pointArray count] > 0){
        
        // Only create a route when there is a path
        
        // Add a polyline
        CustomMKMapView *mapView = [CustomMKMapView sharedManager];
        
        // Construct a MKMapPoint array
        NSMutableArray *mapPointArray = [NSMutableArray array];
        for (NSValue *aValue in [path points]){
            CGPoint aPoint = [aValue CGPointValue];
            
            CLLocationCoordinate2D coord = [mapView convertPoint:aPoint toCoordinateFromView:self];
            [mapPointArray addObject:[NSValue valueWithMKMapPoint:MKMapPointForCoordinate(coord)]];
        }
        
        // Create a route
        Route *aRoute = [[Route alloc] initWithMKMapPointArray:mapPointArray];
        
        // Push the newly created route into the entity database
        EntityDatabase *entityDatabase = [EntityDatabase sharedManager];
        [entityDatabase.entityArray addObject:aRoute];
        aRoute.isMapAnnotationEnabled = YES;
        
        // Update the collection view
        [[TokenCollectionView sharedManager] addItemFromBottom:aRoute];
    }
    
    // Clear the path
    path = nil;
    [self setNeedsDisplay];
}


#pragma mark -- Handling touches --

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    path.lineWidth = IS_IPAD ? 8.0f : 4.0f;
    
    UITouch *touch = [touches anyObject];
    [path moveToPoint:[touch locationInView:self]];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    // Add new points to the path
    UITouch *touch = [touches anyObject];
    [path addLineToPoint:[touch locationInView:self]];
    [self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    [path addLineToPoint:[touch locationInView:self]];
    [self setNeedsDisplay];
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self touchesEnded:touches withEvent:event];
}


- (void)drawRect:(CGRect)rect {
    // Draw the path
    [path stroke];
}

@end
