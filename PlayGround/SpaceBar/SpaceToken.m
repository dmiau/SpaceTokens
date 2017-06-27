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
#import "PersonToken.h"
#import "CustomMKMapView.h"
#import "InformationSheetManager.h"

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
    NSTimer *loopUpdateTimer;
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
    self.frame = CGRectMake(0, 0, SPACE_TOKEN_WIDTH, SPACE_TOKEN_HEIGHT);
    
    self.spatialEntity = [[SpatialEntity alloc] init];
    self.mapViewXY = CGPointMake(0, 0);
        
    // listen to several notification of interest
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(tokenUIUpdateHandler)
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

    [self restoreDefaultStyle];
    
    //----------------
    // Use gesture recognizer by default
    //----------------
    [self initializeGestureRecognizer];
    self.isCustomGestureRecognizerEnabled = YES;
    
    return self;
}

- (void)restoreDefaultStyle{
    [self setBackgroundColor:[UIColor grayColor]];
    
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    if ([self.spatialEntity.name length] > 8){
        self.titleLabel.numberOfLines = 2;
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    }
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
    [self restoreDefaultStyle];
}

- (void)setSelected:(BOOL)selected{
    
    // A dragged SpaceToken does not care about being selected or not.
    // Also, the background should be transparent.
    if (self.appearanceType == DRAGGING){
        [self setBackgroundColor:[UIColor clearColor]];
        return;
    }
    
    super.selected = selected;
    
    if (selected){
        self.backgroundColor = [UIColor redColor];

        // Only shows the line if self is a point token
        if ([self isMemberOfClass:[SpaceToken class]]
            || [self isMemberOfClass:[PersonToken class]]){
            [[self layer] addSublayer:self.lineLayer];
            [self updatePOILine];
        }

        // Populate the information sheet
        CustomMKMapView *mapView = [CustomMKMapView sharedManager];
        [mapView.informationSheetManager addSheetForEntity:self.spatialEntity];
        
        [self startUpdateLoop];
    }else{
        [self restoreDefaultStyle];
        
        if ([self isMemberOfClass:[SpaceToken class]]
            || [self isMemberOfClass:[PersonToken class]]){
            [self.lineLayer removeFromSuperlayer];
        }
        [self cancelUpdateLoop];
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

-(CGPoint)center{
    return super.center;
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
            
            // Round the corner
            self.layer.cornerRadius = 10; // this value vary as per your desire
            self.layer.masksToBounds = NO;
//            self.layer.borderWidth = 1.0f;
            
            // add drop shadow
            self.layer.shadowColor = [UIColor blackColor].CGColor;
            self.layer.shadowOpacity = 0.7f;
            self.layer.shadowRadius = 3.0f;
            self.layer.shadowOffset = CGSizeMake(3.0f, 3.0f);
        
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

- (void)tokenUIUpdateHandler{
    if (self.selected){
        [self updatePOILine];
    }
    
    if (self.isConstraintLineOn){
        [self updateConstraintLine];
    }
}

-(void)startUpdateLoop{
    // Timer action to disable the highlight
    loopUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.02
                                                       target:self
                                                     selector:@selector(tokenUIUpdateHandler)
                                                     userInfo:nil repeats:YES];
}

-(void)cancelUpdateLoop{
    [loopUpdateTimer invalidate];
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
    newToken.didCreateClone = self.didCreateClone;
    return newToken;
}

@end
