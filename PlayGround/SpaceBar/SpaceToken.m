//
//  SpaceMark.m
//  SpaceBar
//
//  Created by Daniel on 2/1/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SpaceToken.h"
#import "UIButton+Extensions.h"
#import "Constants.h"
#import "CustomPointAnnotation.h"
#import "Person.h"
#import "CustomMKMapView.h"


#import "TokenCollectionView.h"

#define SPACE_TOKEN_WIDTH 60
#define SPACE_TOKEN_HEIGHT 28

@interface SpaceToken ()

// Private methods
- (void)privateConfigureDraggingTokenAppearance;
- (void)privateConfigureAnchorAppearanceVisible:(BOOL)visibleFlag;
@end

@implementation SpaceToken{
    NSTimer *tokenFlashTimer;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+(CGSize)getSize{
    return CGSizeMake(SPACE_TOKEN_WIDTH, SPACE_TOKEN_HEIGHT);
}

- (id) init{
    self = [super init];
    
    if (self){
        self.spatialEntity = [[SpatialEntity alloc] init];
        self.mapViewXY = CGPointMake(0, 0);
        

        // listen to several notification of interest
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(mapUpdateHandler)
                       name:MapUpdatedNotification
                     object:nil];
        
        // Appearance Initialization
        self.isCircleLayerOn = NO;
        self.isLineLayerOn = NO;
        self.isConstraintLineOn = NO;
        self.isDraggable = YES;
        self.isStudyModeEnabled = NO;
        
        self.circleLayer = [CAShapeLayer layer];
        self.lineLayer = [CAShapeLayer layer];
        self.constraintLayer = [CAShapeLayer layer];
        
        hasReportedDraggingEvent = NO;
        self.counterPart = nil;
        self.frame = CGRectMake(0, 0, SPACE_TOKEN_WIDTH, SPACE_TOKEN_HEIGHT);
        [self restoreDefaultStyle];
        
        //----------------
        // Use gesture recognizer by default
        //----------------
        [self initializeGestureRecognizer];
        self.isCustomGestureRecognizerEnabled = YES;
    }
    return self;
}

- (void)restoreDefaultStyle{
    [self setBackgroundColor:[UIColor grayColor]];
}

#pragma mark --setters--
//-----------
// setters
//-----------

- (void)setIsCircleLayerOn:(BOOL)isCircleLayerOn{
    _isCircleLayerOn = isCircleLayerOn;
    if (_isCircleLayerOn){
        [[self layer] addSublayer:self.circleLayer];
    }else{
        [self.circleLayer removeFromSuperlayer];
    }
}


- (void)setIsLineLayerOn:(BOOL)isLineLayerOn{
    _isLineLayerOn = isLineLayerOn;
    if (_isLineLayerOn){
        [[self layer] addSublayer:self.lineLayer];
    }else{
        [self.lineLayer removeFromSuperlayer];
    }
}

// This controls the constraint layer
- (void)setIsConstraintLineOn:(BOOL)isConstraintLineOn{
    
    _isConstraintLineOn = isConstraintLineOn;
    if (isConstraintLineOn){
        // Turn off the line and circle layers
        self.isLineLayerOn = NO;
        self.isCircleLayerOn = NO;
        
        // Turn on the constraint layer
        [[self layer] addSublayer:self.constraintLayer];
    }else{
        [self.constraintLayer removeFromSuperlayer];
    }
}

- (void)setSpatialEntity:(SpatialEntity *)spatialEntity{
    _spatialEntity = spatialEntity;
    [self setTitle:spatialEntity.name forState:UIControlStateNormal];
    spatialEntity.linkedObj = self;
}

- (void)setSelected:(BOOL)selected{
    
    // A dragged SpaceToken does not care about being selected or not.
    // Also, the background should be transparent.
    if (self.appearanceType == DRAGGING){
        [self setBackgroundColor:[UIColor clearColor]];
        return;
    }
    
    // Need to cache the original background color
    static UIColor *originalColor;
    if (!self.selected || !originalColor){
        originalColor = [[self backgroundColor] copy];
    }
    
    super.selected = selected;
    
    if (selected){
        self.backgroundColor = [UIColor redColor];
        [[self layer] addSublayer:self.lineLayer];
        [self updatePOILine];
    }else{
        self.backgroundColor = originalColor;
        [self.lineLayer removeFromSuperlayer];
    }
    
    // A SpaceToken may be linked to a dynamic locaiton, such as a person
    if ([self.spatialEntity isKindOfClass:[Person class]]){
        Person *aPerson = (Person*)self.spatialEntity;
        if (selected){
            aPerson.updateFlag = YES;
        }else{
            // http://stackoverflow.com/questions/14924892/nstimer-with-anonymous-function-block
            int64_t delayInSeconds = 5; // Your Game Interval as mentioned above by you
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                // Update your label here.
                aPerson.updateFlag = NO;
            });
        }
    }
}

-(void)setIsCustomGestureRecognizerEnabled:(BOOL)isCustomGestureRecognizerEnabled{
    _isCustomGestureRecognizerEnabled = isCustomGestureRecognizerEnabled;
    if (isCustomGestureRecognizerEnabled){
        [self removeButtonActions];
        [self addGestureRecognizer:tapInterceptor];
    }else{
        [self removeGestureRecognizer:tapInterceptor];
        [self addButtonActions];
    }
}

@synthesize center;
-(void)setCenter:(CGPoint)newCenter{
    [super setCenter:newCenter];
    
    // This is to support the anchor + x feature
    if (self.isConstraintLineOn){
        [self updateConstraintLine];
    }
}

#pragma mark -- Configure Visual Apperarance --

//-----------
// configure the appearance
//-----------
- (void) configureAppearanceForType:(TokenAppearanceType)type{
    
    switch (type) {
        case DOCKED:
            [self addSubview:self.titleLabel];
            [self setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
            self.titleLabel.font = [UIFont systemFontOfSize:12];
            self.selected = NO;
            
            [self setTitleColor: [UIColor whiteColor]
                       forState: UIControlStateNormal];
            self.isLineLayerOn = NO;
            self.isCircleLayerOn = NO;
            
            // add drop shadow
//            self.layer.cornerRadius = 8.0f;
            self.layer.masksToBounds = NO;
//            self.layer.borderWidth = 1.0f;
            
            self.layer.shadowColor = [UIColor grayColor].CGColor;
            self.layer.shadowOpacity = 0.8;
            self.layer.shadowRadius = 12;
            self.layer.shadowOffset = CGSizeMake(12.0f, 12.0f);
            
            self.layer.cornerRadius = 10; // this value vary as per your desire

            
            break;
        case DRAGGING:
            [self privateConfigureDraggingTokenAppearance];

            break;
        case ANCHOR_INVISIBLE:
            [self privateConfigureAnchorAppearanceVisible:NO];
            break;
        case ANCHOR_VISIBLE:
            [self privateConfigureAnchorAppearanceVisible:YES];

            break;
        default:
            break;
    }
    self.appearanceType = type;    
}

- (void)mapUpdateHandler{
    if (self.selected){
        [self updatePOILine];
    }
    
    if (self.isConstraintLineOn){
        [self updateConstraintLine];
    }
    
}


- (void)updatePOILine{
    // draw the line
    UIBezierPath *linePath=[UIBezierPath bezierPath];
    [linePath moveToPoint: CGPointMake(self.frame.size.width/2,
                                       self.frame.size.height/2)];
    [linePath addLineToPoint:
     [self convertPoint:self.mapViewXY fromView:[CustomMKMapView sharedManager]]];
    
    self.lineLayer.path=linePath.CGPath;
    self.lineLayer.fillColor = nil;
    self.lineLayer.opacity = 1.0;
    self.lineLayer.strokeColor = [UIColor blueColor].CGColor;
}

- (void)updateConstraintLine{
    
    //Draw multiple path on a single CALayer
    //http://stackoverflow.com/questions/9967157/multiple-paths-in-cashapelayer
    
    // draw the line
    UIBezierPath *linePath=[UIBezierPath bezierPath];
    [linePath moveToPoint: CGPointMake(self.frame.size.width/2,
                                       self.frame.size.height/2)];
    // Get the map object
    CustomMKMapView *myMapView = [CustomMKMapView sharedManager];
    CGPoint shiftedPOIXY = [myMapView convertCoordinate:self.spatialEntity.latLon
                                          toPointToView:self];
    
    [linePath addLineToPoint: shiftedPOIXY];
    
    
    // Circle path
    float radius = 30;
    UIBezierPath *cirlcePath=[UIBezierPath
                              bezierPathWithOvalInRect:
                              CGRectMake(-radius + shiftedPOIXY.x, -radius + shiftedPOIXY.y,
                                         2*radius, 2*radius)];
    
    // Combine the cirlce path with the line path
    CGMutablePathRef combinedPath = CGPathCreateMutableCopy(linePath.CGPath);
    CGPathAddPath(combinedPath, NULL, cirlcePath.CGPath);
    
    self.constraintLayer.path = combinedPath;
    self.constraintLayer.fillColor = nil;
    self.constraintLayer.strokeColor = [UIColor redColor].CGColor;
    self.constraintLayer.opacity = 1.0;
}

- (void)flashToken{
    [self setBackgroundColor:[UIColor redColor]];
    
    // Timer action to disable the highlight
    tokenFlashTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                         target:self
                                                       selector:@selector(flashTimerAction)
                                                       userInfo:nil repeats:NO];
}

- (void)flashTimerAction{
    [self restoreDefaultStyle];
}

- (void)showAnchorVisualIndicatorAfter:(double) second{
    
    if (second < 0.01){
        self.isCircleLayerOn = YES;
    }else{
        // delay to show the circle layer
        anchorVisualTimer = [NSTimer scheduledTimerWithTimeInterval:second
                                                    target:self
                                                  selector:@selector(anchorTimerAction)
                                                  userInfo:nil repeats:NO];
    }
}

-(void)anchorTimerAction{
    self.isCircleLayerOn = YES;
}


- (NSString*)description{
    NSString *tokenInfo = [NSString stringWithFormat:@"Name: %@", self.titleLabel.text];
    NSString *addressInfo = [NSString stringWithFormat:@"Address: %p", self];
    NSString *mapViewString = NSStringFromCGPoint(self.mapViewXY);
    NSString *pointerString = [NSString stringWithFormat:@"%p", self.touch];
    NSString *latLonString = [NSString stringWithFormat:@"lat: %g, long: %g",
                              self.spatialEntity.latLon.latitude, self.spatialEntity.latLon.longitude];
    
    NSArray *stringArray = [[NSArray alloc] initWithObjects:tokenInfo, addressInfo,
                            mapViewString, pointerString, latLonString, nil];
    NSString *joinedString = [stringArray componentsJoinedByString:@"\n"];
    return joinedString;
}


//------------------
// Deep copy
//------------------
-(id) copyWithZone:(NSZone *) zone
{
    // This is very important, since a child class might call this method too.
    SpaceToken *newToken = [[[self class] alloc] init];
    
    [newToken configureAppearanceForType:self.appearanceType];
    
    [newToken setTitle:self.spatialEntity.name forState:UIControlStateNormal];
    newToken.spatialEntity = self.spatialEntity;
    newToken.spatialEntity.linkedObj = self; // Establish the connection
    newToken.isDraggable = self.isDraggable;
    newToken.home = self.home;
    return newToken;
}

@end
