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
#import "../Map/CustomPointAnnotation.h"
#import "../Map/Person.h"
#import "../Map/customMKMapView.h"

@implementation SpaceToken

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id) init{
    self = [super init];
    
    if (self){
        self.poi = [[POI alloc] init];
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
        self.circleLayer = [CAShapeLayer layer];
        self.lineLayer = [CAShapeLayer layer];
        self.hasReportedDraggingEvent = NO;
        self.counterPart = nil;
        self.frame = CGRectMake(0, 0, 60.0, 20.0);
        [self registerButtonEvents];
        
        
    }
    return self;
}

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

- (void)setPerson:(Person *)person{
    _person = person;
    _poi = person.poi;
}

//-----------
// configure the appearance
//-----------
- (void) configureAppearanceForType:(spaceTokenType)type{
    self.type = type;
    switch (type) {
        case DOCKED:
            [self addSubview:self.titleLabel];
            [self setTitle:@"SpaceToken" forState:UIControlStateNormal];
            [self setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
            self.titleLabel.font = [UIFont systemFontOfSize:12];
//            [self setBackgroundColor:[UIColor grayColor]];
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
            
            break;
        case DRAGGING:
            [self configureDraggingTokenAppearance];
            break;
        case ANCHORTOKEN:
            [self configureDraggingTokenAppearance];
            self.isLineLayerOn = NO;
            self.isCircleLayerOn = NO;
            self.hasReportedDraggingEvent = YES;
            break;
        default:
            break;
    }
    
    
}

//-------------------
// Configure the token as a dragging token
//-------------------
- (void)configureDraggingTokenAppearance{
    self.selected = NO;
    [self setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel removeFromSuperview];
    
    // Draw a circle under the centroid of the button
    
    float radius = 30;
    [self.circleLayer setStrokeColor:[[UIColor blueColor] CGColor]];
    [self.circleLayer setFillColor:[[UIColor clearColor] CGColor]];
    [self.circleLayer setPath:[[UIBezierPath
                                bezierPathWithOvalInRect:
                                CGRectMake(-radius + self.frame.size.width/2, -radius + self.frame.size.height/2, 2*radius, 2*radius)]
                               CGPath]];
    
    [[self layer] addSublayer:self.circleLayer];
    
    float width = 100;
    float height = 30;
    // Add a label on top of the circle
    UILabel *label = [[UILabel alloc] initWithFrame:
                      CGRectMake(-width/2 + self.frame.size.width/2,
                                 -height -radius + self.frame.size.height/2,
                                 width, height)];
    
    label.text = self.poi.name;
    label.textAlignment = NSTextAlignmentCenter;
    [label setTextColor:[UIColor redColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont: [UIFont fontWithName:@"Trebuchet MS" size:12.0f]];
    [self addSubview:label];
    //            [[self layer] addSublayer:self.lineLayer];
}

- (void)setSelected:(BOOL)selected{
    super.selected = selected;
    if (selected){
        self.backgroundColor = [UIColor redColor];
        [[self layer] addSublayer:self.lineLayer];
        [self updatePOILine];
    }else{
        self.backgroundColor = [UIColor grayColor];
        [self.lineLayer removeFromSuperlayer];
    }
    
    // A SpaceToken may be linked to a dynamic locaiton, such as a person
    if (self.person){

        // Get the map object
        customMKMapView *myMapView = [customMKMapView sharedManager];

        if (selected){
            self.person.updateFlag = YES;            
        }else{
            // http://stackoverflow.com/questions/14924892/nstimer-with-anonymous-function-block
            int64_t delayInSeconds = 5; // Your Game Interval as mentioned above by you
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                // Update your label here. 
                self.person.updateFlag = NO;
            });
        }
    }
}

- (void)mapUpdateHandler{
    if (self.selected){
        [self updatePOILine];
    }
}


- (void)updatePOILine{

    // draw the line
    UIBezierPath *linePath=[UIBezierPath bezierPath];
    [linePath moveToPoint: CGPointMake(self.frame.size.width/2,
                                       self.frame.size.height/2)];
    [linePath addLineToPoint:
     [self convertPoint:self.mapViewXY fromView:self.superview]];
    
    self.lineLayer.path=linePath.CGPath;
    self.lineLayer.fillColor = nil;
    self.lineLayer.opacity = 1.0;
    self.lineLayer.strokeColor = [UIColor blueColor].CGColor;
    
}

@end
