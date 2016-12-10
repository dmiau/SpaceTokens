//
//  CollectionViewCell.m
//  lab_CollectionView
//
//  Created by dmiau on 12/5/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor greenColor];
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowRadius = 5.0f;
        self.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
        self.layer.shadowOpacity = 0.5f;
        
        // Selected background view
        UIView *backgroundView = [[UIView alloc]initWithFrame:self.bounds];
        backgroundView.layer.borderColor = [[UIColor colorWithRed:0.529 green:0.808 blue:0.922 alpha:1]CGColor];
        backgroundView.layer.borderWidth = 10.0f;
        self.selectedBackgroundView = backgroundView;
        
        // set content view
        CGRect frame  = CGRectMake(self.bounds.origin.x+5, self.bounds.origin.y+5, self.bounds.size.width-10, self.bounds.size.height-10);
        
        // Add a button
        self.button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
        [self.button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.button setTitle:@"ok" forState:UIControlStateHighlighted];
        
        [self.button setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.button];
        
        
        // Create a label
        label = [[UILabel alloc] init];
        
        label.frame = CGRectMake(5, 5, 50, 20);
//        [self addSubview: label];
        
//        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
//        self.imageView = imageView;
//        [imageView release];
//        self.imageView.contentMode = UIViewContentModeScaleAspectFill ;
//        self.imageView.clipsToBounds = YES;
//        [self.contentView addSubview:self.imageView];       
        
    }
    return self;
}

-(void)setLabelText:(NSString *)labelText{
    _labelText = labelText;
    label.text = labelText;
    
    [self.button setTitle:labelText forState:UIControlStateNormal];
}

@end
