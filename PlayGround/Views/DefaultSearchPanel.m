//
//  DefaultSearchPanel.m
//  SpaceBar
//
//  Created by dmiau on 7/19/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "DefaultSearchPanel.h"
#import "AppDelegate.h"
#import "ViewController.h"

@implementation DefaultSearchPanel

- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self){
        
        // set up the color of the view
        [self setBackgroundColor:[UIColor colorWithRed: 0.97 green:0.97 blue:0.97
                                                 alpha:1.0]];
        
        // add a button to access the preference panel
        UIButton*  preferenceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        preferenceButton.frame =
        CGRectMake(frame.size.width*0.05, frame.size.height*0.5, 60, 20);
        [preferenceButton setTitle:@"Pref." forState:UIControlStateNormal];
        preferenceButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [preferenceButton setBackgroundColor:[UIColor grayColor]];
        [preferenceButton addTarget:self action:@selector(preferenceButtonAction)
                forControlEvents:UIControlEventTouchDown];

        // add drop shadow
        //            self.layer.cornerRadius = 8.0f;
        preferenceButton.layer.masksToBounds = NO;
        //            self.layer.borderWidth = 1.0f;
        
        preferenceButton.layer.shadowColor = [UIColor grayColor].CGColor;
        preferenceButton.layer.shadowOpacity = 0.8;
        preferenceButton.layer.shadowRadius = 12;
        preferenceButton.layer.shadowOffset = CGSizeMake(12.0f, 12.0f);
        [self addSubview:preferenceButton];
        
        
        // add a button to access the data panel
        UIButton*  dataButton = [UIButton buttonWithType:UIButtonTypeCustom];
        dataButton.frame =
        CGRectMake(frame.size.width*0.8, frame.size.height*0.5, 60, 20);
        [dataButton setTitle:@"Data" forState:UIControlStateNormal];
        dataButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [dataButton setBackgroundColor:[UIColor grayColor]];
        [dataButton addTarget:self action:@selector(dataButtonAction)
                   forControlEvents:UIControlEventTouchDown];
        [self addSubview:dataButton];

    }
    
    return self;
}


- (void)preferenceButtonAction{        
    //-------------------
    // Set the rootViewController
    //-------------------
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    ViewController *rootViewController =
    app.window.rootViewController;

    [rootViewController performSegueWithIdentifier:@"PreferencesSegue"
                                            sender:nil];
}

- (void)dataButtonAction{
    //-------------------
    // Set the rootViewController
    //-------------------
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    ViewController *rootViewController =
    app.window.rootViewController;
    
    [rootViewController performSegueWithIdentifier:@"DataSegue"
                                            sender:nil];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
