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
    }
    return self;
}

// factory method
- (id) initForType: (spaceTokenType)type{
    self = [self init];
    self.type = type;
    
    switch (type) {
        case DOCKED:
            self.circleLayer = [CAShapeLayer layer];
            self.lineLayer = [CAShapeLayer layer];
            [self resetButton];
            self.frame = CGRectMake(0, 0, 60.0, 20.0);
            [self registerButtonEvents];
            break;
        case DRAGGING:
            
            break;
            
        case ANCHORTOKEN:
            break;

        case DOT:
            
            break;
            
        default:
            break;
    }
    
    return self;
}


- (void)setPerson:(Person *)person{
    _person = person;
    _poi = person.poi;
}


//-----------
// reattach to a superview
//-----------
- (void) resetButton{
    self.hasReportedDraggingEvent = [NSNumber numberWithBool:NO];
    self.counterPart = nil;
    [self configureAppearanceForType:DOCKED];
}


//-----------
// configure the appearance
//-----------
- (void) configureAppearanceForType:(spaceTokenType)type{
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
            [self.circleLayer removeFromSuperlayer];
            [self.lineLayer removeFromSuperlayer];
            
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
            [[self layer] addSublayer:self.lineLayer];
            break;
        default:
            break;
    }
    
    
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
