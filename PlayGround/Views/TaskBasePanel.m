//
//  TaskBasePanel.m
//  SpaceBar
//
//  Created by dmiau on 8/7/16.
//  Copyright © 2016 dmiau. All rights reserved.
//
#import "AppDelegate.h"
#import "ViewController.h"
#import "SettingsButton.h"
#import "TaskBasePanel.h"
#import "../StudyManager/SnapshotProgress.h"
#import "../StudyManager/SnapshotChecking.h"

@implementation TaskBasePanel{
    SettingsButton *settingsButton;
}

// http://stackoverflow.com/questions/4609609/use-singleton-in-interface-builder
static TaskBasePanel *instance;

+ (id)sharedManager { return instance; }

+ (id)hiddenAlloc
{
    return [super alloc];
}

+ (id)alloc
{
    return [self sharedManager];
}

+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        instance = [[TaskBasePanel hiddenAlloc] init];
    }
}


- (id)initWithFrame:(CGRect)frame ViewController:(ViewController*) viewController{
    
    self = [TaskBasePanel sharedManager];
    self.frame = frame;
    if (self){
        
        self.rootViewController = viewController;
        
        //-------------------
        // Set up the view
        //-------------------
        // set up the color of the view
        [self setBackgroundColor:[UIColor colorWithRed: 0.94 green:0.94 blue:0.94
                                                 alpha:1.0]];
        settingsButton = [[SettingsButton alloc] init];
        
        //-------------------
        // Load all the panels
        //-------------------
        
        
    }
    
    return self;
}

- (void)addPanel{
    
    float panelHeight = self.rootViewController.view.frame.size.height -
    self.rootViewController.mapView.frame.size.height;
    // Move the map to the top
    float mapWidth = self.rootViewController.mapView.frame.size.width;
    float mapHeight = self.rootViewController.mapView.frame.size.height;
    self.rootViewController.mapView.frame = CGRectMake(0, 0, mapWidth, mapHeight);
    
    // Set up the frame of the panel
    self.frame = CGRectMake(0, mapHeight, mapWidth, panelHeight);
    [self.rootViewController.view addSubview:self];
    
    // Add the preference button
    settingsButton.frame = CGRectMake(0, 30, 30, 30);
    [self.rootViewController.view addSubview: settingsButton];
}


- (void)removePanel{
    // Remove the settings button
    [settingsButton removeFromSuperview];
    [self removeFromSuperview];
    
    // Restore the location of the map
    float panelHeight = self.rootViewController.view.frame.size.height -
    self.rootViewController.mapView.frame.size.height;
    // Move the map to the top
    float mapWidth = self.rootViewController.mapView.frame.size.width;
    float mapHeight = self.rootViewController.mapView.frame.size.height;
    self.rootViewController.mapView.frame = CGRectMake(0, panelHeight, mapWidth, mapHeight);
}

- (void)configureForSnapshot:(id <SnapshotProtocol>) snapshot{
    if ([snapshot isKindOfClass:[SnapshotProgress class]]){
        
    }
    
    
    
    
//    switch (taskType) {
//        case CHECKING:
//            [self configureChecking];
//            break;
//        case PROGRESS:
//            [self configureProgress];
//            break;
//            //        case SCLAE:
//            //            <#statements#>
//            //            break;
//            //        case JUMP:
//            //            <#statements#>
//            //            break;
//            //        case ZOOMTOFIT:
//            //            <#statements#>
//            //            break;
//        default:
//            break;
//    }
}

- (void)configureChecking{
    
}

- (void)configureProgress{
    
}
@end
