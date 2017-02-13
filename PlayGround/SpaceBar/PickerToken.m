//
//  PickerToken.m
//  SpaceBar
//
//  Created by Daniel on 2/1/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "PickerToken.h"
#import "SpaceToken.h"
#import "WildcardGestureRecognizer.h"
#import "TokenCollection.h"
#import "TokenCollectionView.h"
#import "EntityDatabase.h"
#import "HighlightedEntities.h"
#import "CustomPointAnnotation.h"

@implementation PickerToken{
    CAShapeLayer *lineLayer; // shows the line connecting the SpaceToken and the actual location
    BOOL isLineLayerOn;
    NSMutableArray *touchHistory;
    BOOL probEnabled;
    // The prob needs to be turn off once a token is added. This is to avoid duplicate additions.
    
    WildcardGestureRecognizer * tapInterceptor;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id) init{
    self = [super init];
    
    CGSize tokenSize = [SpaceToken getSize];
    // The same should be the same as the size of a SpaceToken
    self.frame = CGRectMake(0, 0, tokenSize.width, tokenSize.height);
    
    // Configure the color and style
    [self restoreDefaultStyle];
    self.multipleTouchEnabled = YES;
    
    // Instantiate instance variables
    probEnabled = NO;
    isLineLayerOn = NO;
    lineLayer = [CAShapeLayer layer];
    
    [self initializeGestureRecognizer];
    
    return self;
}


- (void)restoreDefaultStyle{
    UIImage *pickerIcon = [UIImage imageNamed:@"pickerIcon"];
    
    [self setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.4]];
    [self setBackgroundImage:pickerIcon forState:UIControlStateNormal];
    
    // add drop shadow
    self.layer.cornerRadius = 10; // this value vary as per your desire
    self.layer.masksToBounds = NO;
    //            self.layer.borderWidth = 1.0f;
    self.layer.shadowColor = [UIColor grayColor].CGColor;
    self.layer.shadowOpacity = 0.8;
    self.layer.shadowRadius = 12;
    self.layer.shadowOffset = CGSizeMake(12.0f, 12.0f);
}

- (void)setSelected:(BOOL)selected{
}


// MARK: Gesture recognizer
//-------------------
// Initialize gesture recognizer
//-------------------
-(void)initializeGestureRecognizer{
    //-----------------
    // Initialize custom gesture recognizer
    //-----------------
    
    // Q: Why do I need to use a custom gesture recognizer?
    // A1: Because I need to disable the default rotation gesture recognizer
    // A2: I don't want my touch to be cancelled by other gesture recognizer
    // (http://stackoverflow.com/questions/5818692/how-to-avoid-touches-cancelled-event)
    
    tapInterceptor = [[WildcardGestureRecognizer alloc] init];
    
    tapInterceptor.touchesBeganCallback = ^(NSSet<UITouch*>* touches, UIEvent * event) {
        [self customTouchesBegan:touches withEvent:event];
    };
    
    tapInterceptor.touchesEndedCallback = ^(NSSet<UITouch*>* touches, UIEvent * event) {
        [self customTouchesEnded:touches withEvent:event];
    };
    
    tapInterceptor.touchesMovedCallback = ^(NSSet<UITouch*>* touches, UIEvent * event) {
        [self customTouchesMoved:touches withEvent:event];
    };
    
    tapInterceptor.touchesCancelledCallback = ^(NSSet<UITouch*>* touches, UIEvent * event) {
        [self customTouchesCancelled:touches withEvent:event];
    };
    
    tapInterceptor.delegate = self;
    [self addGestureRecognizer:tapInterceptor];
}


#pragma mark -- Gesture methods --
-(void) customTouchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    // This is to prevent the pickertool from moving when it is being dragged
    [[TokenCollectionView sharedManager] setScrollEnabled:NO];
    
    touchHistory = [NSMutableArray array];
    
    // Assuming there is only one touch
    UITouch *touch = [touches anyObject];
    probEnabled = YES;
    CGPoint touchPoint = [touch locationInView:self];
    [touchHistory addObject: [NSNumber valueWithCGPoint:touchPoint]];
}

-(void)customTouchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    
    if (!probEnabled){
        [self customTouchesEnded:touches withEvent:event];
        return;
    }
    
    // Check if the connection tool is activated
    if ([self probeEntity:touches]){
        [self customTouchesEnded:touches withEvent:event];
    }
}


-(void)customTouchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [[TokenCollectionView sharedManager] setScrollEnabled:YES];
    [lineLayer removeFromSuperlayer];
    touchHistory = nil;
}

-(void)customTouchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [[TokenCollectionView sharedManager] setScrollEnabled:YES];
    [lineLayer removeFromSuperlayer];
    touchHistory = nil;
}

//-----------------
// Connection tools
//-----------------

- (BOOL)probeEntity:(NSSet<UITouch *> *)touches{
    
    
    
    static BOOL movingOut = false;
    static CGPoint initOutLocation;
    
    // This only works when a single point is touched
    if ([touches count] > 1)
        return NO;
    
    UITouch *touch = [touches anyObject];
    
    CGPoint currentLocation = [touch locationInView:self];
    CGPoint previousLocation = [[touchHistory lastObject] CGPointValue];
    
    
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    
    if (CGRectContainsPoint(self.bounds, previousLocation) &&
        !CGRectContainsPoint(self.bounds, currentLocation))
    {
        movingOut = YES;
        initOutLocation = previousLocation;
        
        // Add the line layer to mapView
        [[mapView layer] addSublayer: lineLayer];
    }else{
        [touchHistory addObject:[NSNumber valueWithCGPoint:currentLocation]];
        return NO;
    }
    
    // Draw the line
    if (movingOut){
        // Draw a line
        // draw the line
        UIBezierPath *linePath=[UIBezierPath bezierPath];
        

        initOutLocation.x = self.bounds.size.width/2;
        initOutLocation.y = self.bounds.size.height/2;
        
        [linePath moveToPoint: [self convertPoint:initOutLocation toView:mapView]];
        [linePath addLineToPoint: [self convertPoint:currentLocation toView:mapView]];
        
        lineLayer.path=linePath.CGPath;
        lineLayer.fillColor = nil;
        lineLayer.opacity = 1.0;
        lineLayer.lineWidth = 4.0f;
        lineLayer.strokeColor = [UIColor blueColor].CGColor;
    }
    
    // Check if the connection tool touch any token?
    // Get the TokenCollection object
    
    CGPoint touchPoint = [self convertPoint:currentLocation toView:mapView];
    CGPoint previoustouchPoint = [self convertPoint:previousLocation toView:mapView];
    
    
    for (SpaceToken *aToken in [[TokenCollection sharedManager] getTokenArray]){
        
        // Convert buttonFrame to be in mapView
        CGRect buttonInMapView = [aToken.superview convertRect:aToken.frame toView:mapView];
        
        // Make sure the route creation tool is only triggered once
        if (CGRectContainsPoint(buttonInMapView, touchPoint)
            &&
            !CGRectContainsPoint(buttonInMapView, previoustouchPoint)
            && probEnabled)
        {
            SpatialEntity *entity = aToken.spatialEntity;
            probEnabled = NO;
            movingOut = NO;
            entity.annotation.pointType = STAR;
            entity.dirtyFlag = @0;
            entity.isEnabled = YES;
            [[EntityDatabase sharedManager] addEntity:entity];
            
            [[TokenCollectionView sharedManager] reloadData];
            [lineLayer removeFromSuperlayer];
            
            return YES;
        }
    }
    
    //------------------------
    // Else, check if the addition tool touches a highlighed entity
    //------------------------
    
    NSSet *highlightedSet = [[HighlightedEntities sharedManager] getHighlightedSet];
    
    for (SpatialEntity *highlightedEntity in highlightedSet){
        if ([highlightedEntity isEntityTouched:touch] && probEnabled){
            probEnabled = NO;
            movingOut = NO;
            highlightedEntity.annotation.pointType = STAR;
            highlightedEntity.dirtyFlag = @0;
            highlightedEntity.isEnabled = YES;
            [[EntityDatabase sharedManager] addEntity:highlightedEntity];
            
            [[TokenCollectionView sharedManager] reloadData];
            [lineLayer removeFromSuperlayer];
            
            return YES;
        }
    }
    
    return NO;
}




@end
