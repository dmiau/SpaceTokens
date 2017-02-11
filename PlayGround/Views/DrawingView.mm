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
#import "Area.h"
#import "EntityDatabase.h"
#import "TokenCollectionView.h"
#include <algorithm>
#import "ToolPalette.h"
#import "HighlightedEntities.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM () == UIUserInterfaceIdiomPad)

typedef struct {
    CGPoint startPoint;
    CGPoint endPoint;
} Line;

#define CGPointNULL CGPointMake(NAN, NAN)

#define Line(_i_) {CGPointFromString(touchPoints[_i_-1]), CGPointFromString(touchPoints[_i_])};

using namespace std;

@implementation DrawingView

-(id)init{
    self = [super init];
    if (self){
        self.drawingModeEnabled = NO;
        
        //--------------------
        // Load the tool palette
        //--------------------
        self.toolPalette = [[[NSBundle mainBundle] loadNibNamed:@"ToolPalette" owner:self options:nil] firstObject];
        self.toolPalette.drawingView = self;
        
    }
    return self;
}

-(void)viewWillAppear{
    // Add the tool palette to the view (only once)
    static BOOL once = false;
    if (!once){
        // Configure tool palette
        [self addSubview:self.toolPalette];
        // Configure the position of toolPalette
        CGPoint toolPaletteOrigin = CGPointMake(0, self.frame.size.height - self.toolPalette.frame.size.height);
        CGRect toolPaletteFrame = self.toolPalette.frame;
        toolPaletteFrame.origin = toolPaletteOrigin;
        self.toolPalette.frame = toolPaletteFrame;
        once = true;
    }
    [self.toolPalette setHidden:YES];
    self.drawingModeEnabled = YES;
}

-(void)viewWillDisappear{
    self.drawingModeEnabled = NO;
}


// Control the transparency of the view
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // UIView will be "transparent" for touch events if we return NO
    
    if (self.drawingModeEnabled){
        if (point.y > 0 && point.y < self.frame.size.height)
            return YES;
    }else{
        CGRect toolRect = self.toolPalette.frame;
        if (CGRectContainsPoint(toolRect, point)){
            return YES;
        }        
    }
    return NO;
}


// MARK: Setters
-(void)setDrawingModeEnabled:(BOOL)drawingModeEnabled{
    _drawingModeEnabled = drawingModeEnabled;
    if (drawingModeEnabled){
        [self setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.2]];
        
        
        // Prepare the drawing environment
        touchPointArray = [NSMutableArray array];
        isArea = NO;
        
        bezierPathArray = [NSMutableArray array];
    }else{
        [self bakeDrawingToMap];
        [self setBackgroundColor:[UIColor clearColor]];
    }
}

// Bake the drawing to the map
-(void)bakeDrawingToMap{
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    
    // Bake the path on to the map
    UIBezierPath *path = [bezierPathArray firstObject];
    NSArray *pointArray = [path points];
    
    if ([pointArray count] > 0){
        
        // Only create a route when there is a path
        
        // Add a polyline
        // Construct a MKMapPoint array
        NSMutableArray *mapPointArray = [NSMutableArray array];
        for (NSValue *aValue in pointArray){
            CGPoint aPoint = [aValue CGPointValue];
            
            CLLocationCoordinate2D coord = [mapView convertPoint:aPoint toCoordinateFromView:self];
            [mapPointArray addObject:[NSValue valueWithMKMapPoint:MKMapPointForCoordinate(coord)]];
        }
        
        SpatialEntity *newEntity;
        if (!isArea){
            //------------------
            // Baking a sketched line
            //------------------
            Route *aRoute = [[Route alloc] initWithMKMapPointArray:mapPointArray];
            aRoute.name = @"sketchedLine";
            newEntity = aRoute;
        }else{
            //------------------
            // Baking a sketched area
            //------------------
            
            // First need to close the path
            CGPoint aPoint = [[pointArray firstObject] CGPointValue];
            CLLocationCoordinate2D coord = [mapView convertPoint:aPoint toCoordinateFromView:self];
            [mapPointArray addObject:[NSValue valueWithMKMapPoint:MKMapPointForCoordinate(coord)]];
            
            Area *anArea = [[Area alloc] initWithMKMapPointArray:mapPointArray];
            anArea.name = @"sketchedArea";
            newEntity = anArea;
        }
        
        // Push the newly created route into the entity database
        [[EntityDatabase sharedManager] addEntity:newEntity];
        [[HighlightedEntities sharedManager] clearAllHIghlightedEntitiesButType:SEARCH_RESULT];
        [[HighlightedEntities sharedManager] addEntity:newEntity];
    }
    
    // Clear the path
    [self setNeedsDisplay];
}

#pragma mark -- Handling touches --

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    if (!self.drawingModeEnabled)
        return;
    
    // Initialize a new path for the user gesture
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = IS_IPAD ? 8.0f : 4.0f;
    [bezierPathArray addObject:path];
    
            
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    [path moveToPoint:touchPoint];
//    [touchPointArray addObject:NSStringFromCGPoint(touchPoint)];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if (!self.drawingModeEnabled)
        return;
    
    // Add new points to the path
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    [[bezierPathArray lastObject] addLineToPoint:touchPoint];
    
    if ([self isAreaDrawn]){
        isArea = YES;
        [self touchesEnded:touches withEvent:event];
        NSLog(@"Area detected!");
    }
    
    
//    // Check intersection
//    CGPoint intersectionPoint = [self mostOuterIntersection:touchPointArray];
//    if (!isnan(intersectionPoint.x) && !isnan(intersectionPoint.y)){
//        NSLog(@"Intersection detected!");
//        isArea = YES;
//        [touchPointArray addObject:NSStringFromCGPoint(intersectionPoint)];
//        [self touchesEnded:touches withEvent:event];
//    }
//    [touchPointArray addObject:NSStringFromCGPoint(touchPoint)];
    
    [self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!self.drawingModeEnabled)
        return;
    UITouch *touch = [touches anyObject];
    [[bezierPathArray lastObject] addLineToPoint:[touch locationInView:self]];
    [self setNeedsDisplay];

}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!self.drawingModeEnabled)
        return;
    [self touchesEnded:touches withEvent:event];
}


- (void)drawRect:(CGRect)rect {
    if (!self.drawingModeEnabled)
        return;
    
    UIColor *strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
    [strokeColor setStroke];
    
    UIColor *fillColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
    [fillColor setFill];
    
    if (!isArea){
        for (UIBezierPath *path in bezierPathArray){
            [path stroke];
        }
    }else{
        UIBezierPath *path = [bezierPathArray firstObject];
        // This closes the copy of your drawing path.
        [path closePath];
        
        // Stroke the path after filling it so that you can see the outline
        [path fill]; // this will fill a closed path
        [path stroke]; // this will stroke the outline of the path.
    }
}


//-------------------
// Detect area
//-------------------
-(BOOL)isAreaDrawn{
    // Area drawing must contain more than two paths
    if ([bezierPathArray count] <2)
        return NO;
    
    // Detect the distace between the start and end points of the first path
    UIBezierPath *path1 = [bezierPathArray firstObject];
    NSArray *pointArray = [path1 points];
    CGPoint a = [[pointArray firstObject] CGPointValue];
    CGPoint b = [[pointArray lastObject] CGPointValue];
    double distance = pow((a.x - b.x), 2) + pow((a.y - b.y), 2);
    
//    // Check the distance between the start and the end
//    if (distance < 900)
//        return NO;
    
    // Compute the bounding box of the first path
    CGRect firstBoundingBox = [self computeBoundingBox:pointArray];
    float area1 = firstBoundingBox.size.width * firstBoundingBox.size.height;
    
    // Compute the bounding box of the remaining path
    UIBezierPath *path2 = bezierPathArray[1];
    NSArray *pointArray2 = [path2 points];
    CGRect secondBoundingBox = [self computeBoundingBox:pointArray2];
    float area2 = secondBoundingBox.size.width * secondBoundingBox.size.height;
    
    if (area2 > 0.9*area1)
        return YES;
    else
        return NO;
}

// Compute the bounding box of an array of points
-(CGRect)computeBoundingBox:(NSArray<NSValue*> *)pointArray{
    float xMin = 0, xMax = 0, yMin = 0, yMax = 0;
    for (NSValue *aValue in pointArray){
        CGPoint aPoint = [aValue CGPointValue];
        xMin = fmin(xMin, aPoint.x);
        xMax = fmax(xMax, aPoint.x);
        yMin = fmin(yMin, aPoint.y);
        yMax = fmax(yMax, aPoint.y);
    }
    CGRect outRect = CGRectZero;
    outRect.origin = CGPointMake(xMin, yMin);
    outRect.size = CGSizeMake(xMax - xMin, yMax - yMin);
    return outRect;
}

// Tools for checking line interactions
//http://stackoverflow.com/questions/12909008/how-to-find-the-closing-pathtwo-line-intersection-in-iphone-sdk
- (CGPoint)mostOuterIntersection:(NSArray *)touchPoints {
    CGPoint intersection = CGPointNULL;
    int touchCount = [touchPoints count];
    
    if (touchCount > 1){
        for(int i = 1; i<touchCount-1; i++) {
            Line first = Line(i);
            
            int j = touchCount-1;
            Line last = Line(j);
            intersection = LineIntersects(&first, &last);
            if( !isnan(intersection.x) && !isnan(intersection.y)) {
                return intersection;
            }
            
        }
        
    }
    return intersection;
}

// Check if two lines intersect
CGPoint LineIntersects(Line *first, Line *second) {
    int x1 = first->startPoint.x; int y1 = first->startPoint.y;
    int x2 = first->endPoint.x; int y2 = first->endPoint.y;
    
    int x3 = second->startPoint.x; int y3 = second->startPoint.y;
    int x4 = second->endPoint.x; int y4 = second->endPoint.y;
    
    int d = (x1-x2)*(y3-y4) - (y1-y2)*(x3-x4);
    
    if (d == 0) return CGPointNULL;
    
    int xi = ((x3-x4)*(x1*y2-y1*x2)-(x1-x2)*(x3*y4-y3*x4))/d;
    int yi = ((y3-y4)*(x1*y2-y1*x2)-(y1-y2)*(x3*y4-y3*x4))/d;
    
    // Check if the intersected point C, is in between the segmetn A, B
    CGPoint A = CGPointMake(x1, y1), B = CGPointMake(x2, y2);
    CGPoint C = CGPointMake(xi, yi);
    
    CGPoint D = CGPointMake(x3, y3), E = CGPointMake(x4, y4);
    if (isBetween(A, B, C) && isBetween(D, E, C)){
        return CGPointMake(xi,yi);
    }else{
        return CGPointNULL;
    }
}

//http://stackoverflow.com/questions/328107/how-can-you-determine-a-point-is-between-two-other-points-on-a-line-segment
BOOL isBetween(CGPoint a, CGPoint b, CGPoint c){
//    float crossproduct = (c.y - a.y) * (b.x - a.x) - (c.x - a.x) * (b.y - a.y);
    //    // Check if the points is aligned
    //    if (abs(crossproduct) > 0.01)
    //        return NO;
    float dotproduct = (c.x - a.x) * (b.x - a.x) + (c.y - a.y)*(b.y - a.y);
    if (dotproduct < .001)
        return NO;
    
    float squaredlengthba = (b.x - a.x)*(b.x - a.x) + (b.y - a.y)*(b.y - a.y);
    if (dotproduct > squaredlengthba)
        return NO;
    else
        return YES;
}

//------------------
// Initialize a clear button
//------------------
- (void)initClearButton{
    //------------------
    // Add a direction button for testing
    //------------------
    clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    clearButton.frame = CGRectMake(0, 0, 60, 20);
    [clearButton setTitle:@"clear" forState:UIControlStateNormal];
    clearButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [clearButton setBackgroundColor:[UIColor grayColor]];
    [clearButton addTarget:self action:@selector(clearButtonAction)
              forControlEvents:UIControlEventTouchDown];
    
    // add drop shadow
    //            self.layer.cornerRadius = 8.0f;
    clearButton.layer.masksToBounds = NO;
    //            self.layer.borderWidth = 1.0f;
    
    clearButton.layer.shadowColor = [UIColor grayColor].CGColor;
    clearButton.layer.shadowOpacity = 0.8;
    clearButton.layer.shadowRadius = 12;
    clearButton.layer.shadowOffset = CGSizeMake(12.0f, 12.0f);
}

- (void)clearButtonAction{
    
}
@end
