//
//  CustomPointAnnotation.m
//  SpaceBar
//
//  Created by dmiau on 8/16/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "CustomPointAnnotation.h"
#import "CustomMKMapView.h"
#import "UIImage+tools.h"
#import "StarIconGenerator.h"
#import "DiskGenerator.h"

@implementation CustomPointAnnotation{
    UILabel *aLabel;
    
    UIImage *starImg;
    UIImage *highlightedStarImg;
    
    UIImage *grayDotImg;
    UIImage *highlightedGrayDotImg;
    
    UIImage *redDotImg;
    UIImage *highlightedRedDotImg;
    
    UIImage *youRHereImg;
}

-(id)init{
    self = [super init];
    
    _isLabelOn = NO;
    self.pointType = DEFAULT_MARKER;
    // Initialize the label
    aLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 45, 20)];
    
    
    
    // Preload all the images
    StarIconGenerator *starGenerator = [[StarIconGenerator alloc] init];
    starGenerator.isMarkerOn = NO;
    starImg = [starGenerator generateIcon];
    
    starGenerator.isMarkerOn = YES;
    highlightedStarImg = [starGenerator generateIcon];
    
    DiskGenerator *diskGenerator = [[DiskGenerator alloc] init];
    diskGenerator.diskStyle = GRAYDISK;
    grayDotImg = [diskGenerator generateIcon];
    
    diskGenerator.diskStyle = REDDISK;
    redDotImg = [diskGenerator generateIcon];
    diskGenerator.isMarkerOn = YES;
    highlightedRedDotImg = [diskGenerator generateIcon];
    
    youRHereImg = [[UIImage imageNamed:@"grayYouRHere.png"]  resize:CGSizeMake(12, 12)];
    return self;
}


-(void)setPointType:(location_enum)pointType{
    _pointType = pointType;
    
    if (pointType == LANDMARK){
        //--------------------------
        // Create a custom gray dot
        //--------------------------
        self.iconGenerator = [[DiskGenerator alloc] init];
        self.iconGenerator.fillColor = [UIColor grayColor];
    }else if(pointType == YouRHere){        
        //--------------------------
        // YouRHere
        //--------------------------
        self.iconGenerator = [[DiskGenerator alloc] init];
        self.iconGenerator.fillColor = [UIColor blueColor];

    }else if(pointType == STAR){
        //--------------------------
        // A star image
        //--------------------------
        self.iconGenerator = [[StarIconGenerator alloc] init];

    }else if(pointType == SEARCH_RESULT){
        //--------------------------
        // Search result (red dot)
        //--------------------------
        self.iconGenerator = [[DiskGenerator alloc] init];
        self.iconGenerator.fillColor = [UIColor redColor];

    }else{
        self.iconGenerator = nil;

    }
    
    if (self.iconGenerator){
        self.iconGenerator.isMarkerOn = self.isHighlighted;
        self.infoWindowAnchor = CGPointMake(0.5, 0.5);
        self.groundAnchor = CGPointMake(0.5, 0.5);
    }else{
        self.infoWindowAnchor = CGPointMake(0.5, 0);
        self.groundAnchor = CGPointMake(0.5, 1);
        self.icon = nil;
    }
    
    self.isHighlighted = self.isHighlighted; // reflect the highlight status
}

//--------------
// Setters
//--------------
-(void)setIsHighlighted:(BOOL)isHighlighted{
    _isHighlighted = isHighlighted;
    
    
    
    if (self.pointType == YouRHere){
        self.iconView = nil;
        self.iconGenerator.isMarkerOn = NO;
        if (isHighlighted){
            self.iconGenerator.fillColor = [UIColor blueColor];
        }else{
            self.iconGenerator.fillColor = [UIColor grayColor];
        }
        self.icon = [self.iconGenerator generateIcon];
    }else{
        self.iconGenerator.isMarkerOn = isHighlighted;
        if (isHighlighted){
            //-------------------
            // highlighted
            //-------------------
            if (self.iconGenerator){
                UIImageView *imageView = [[UIImageView alloc]
                                          initWithImage: [self.iconGenerator generateIcon]];
                [imageView addSubview:aLabel];
                self.iconView = imageView;
                [aLabel setTextColor: [UIColor redColor]];
            }
        }else{
            
            //-------------------
            // normal
            //-------------------
            self.iconView = nil;
            if (self.iconGenerator){
                self.icon = [self.iconGenerator generateIcon];
            }else{
                self.map = nil;
            }
        }
    }
}

-(void)setTitle:(NSString *)title{
    [super setTitle:title];
    aLabel.backgroundColor = [UIColor clearColor];
    aLabel.textColor = [UIColor blackColor];
//    self.aLabel.alpha = 0.5;
    aLabel.text = title;
    aLabel.adjustsFontSizeToFitWidth = YES;
    aLabel.numberOfLines = 2;
}

-(void)setIsLabelOn:(bool)isLabelOn{
    _isLabelOn = isLabelOn;
}
@end


