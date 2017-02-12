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

    // Backup
//    starImg = [[UIImage imageNamed:@"star-250.png"] resize:CGSizeMake(24, 24)];
//    
//    highlightedStarImg = [[UIImage imageNamed:@"selectedStar-250.png"] resize:CGSizeMake(24, 24)];
//    grayDotImg = [self generateDotImageWithColor:[UIColor grayColor] andRadius:6];
//    redDotImg = [self generateDotImageWithColor:[UIColor redColor] andRadius:6];
    
    return self;
}


-(void)setPointType:(location_enum)pointType{
    _pointType = pointType;
    
    if (pointType == LANDMARK){
        //--------------------------
        // Create a custom gray dot
        //--------------------------
        self.icon = grayDotImg;
        self.infoWindowAnchor = CGPointMake(0.5, 0.5);
        self.groundAnchor = CGPointMake(0.5, 0.5);
        
    }else if(pointType == YouRHere){        
        //--------------------------
        // YouRHere
        //--------------------------
        self.icon = youRHereImg;
        self.infoWindowAnchor = CGPointMake(0.5, 0.5);
        self.groundAnchor = CGPointMake(0.5, 0.5);
        
    }else if(pointType == STAR){
        //--------------------------
        // A star image
        //--------------------------
        self.icon = starImg;
        self.infoWindowAnchor = CGPointMake(0.5, 0.5);
        self.groundAnchor = CGPointMake(0.5, 0.5);
    }else if(pointType == SEARCH_RESULT){
        //--------------------------
        // Search result (red dot)
        //--------------------------
        self.icon = redDotImg;
        self.infoWindowAnchor = CGPointMake(0.5, 0.5);
        self.groundAnchor = CGPointMake(0.5, 0.5);
    }else{
        self.icon = nil;
        self.infoWindowAnchor = CGPointMake(0.5, 0);
        self.groundAnchor = CGPointMake(0.5, 1);
    }
    
    self.isHighlighted = self.isHighlighted; // reflect the highlight status
}

//--------------
// Setters
//--------------
-(void)setIsHighlighted:(BOOL)isHighlighted{
    _isHighlighted = isHighlighted;
    
    if (isHighlighted){
        //-------------------
        // highlighted
        //-------------------
        
        if (self.pointType == LANDMARK){
            self.icon = redDotImg;
        }else if (self.pointType == STAR){
//            self.icon = highlightedStarImg;
            UIImageView *imageView = [[UIImageView alloc] initWithImage: highlightedStarImg];
            [imageView addSubview:aLabel];
            [aLabel setTextColor: [UIColor redColor]];
            self.iconView = imageView;
        }else if (self.pointType == SEARCH_RESULT){
            self.icon = highlightedRedDotImg;
        }

    }else{
        
        //-------------------
        // normal
        //-------------------
//        self.pointType = self.pointType;
        if (self.pointType == LANDMARK){
            self.icon = grayDotImg;
        }else if (self.pointType == STAR){
            self.iconView = nil;
            self.icon = starImg;
        }else if (self.pointType == SEARCH_RESULT){
            self.icon = redDotImg;
        }else{
            self.map = nil;
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


