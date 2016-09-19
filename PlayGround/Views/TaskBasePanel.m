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
#import "GameManager.h"

@implementation TaskBasePanel{
    SettingsButton *settingsButton;
    NSDate *startDate;
    NSTimer *updateTimer;
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

- (id)init
{
    if(instance==nil) // allow only to be called once
    {
        // your normal initialization here
        
        // Connect to the parent view controller to update its
        // properties directly
        
        //-------------------
        // Set the rootViewController
        //-------------------
        AppDelegate *app = [[UIApplication sharedApplication] delegate];
        
        UINavigationController *myNavigationController =
        app.window.rootViewController;
        self.rootViewController = [myNavigationController.viewControllers objectAtIndex:0];
        
        //-------------------
        // Set up the view
        //-------------------
        // set up the color of the view
        [self setBackgroundColor:[UIColor colorWithRed: 0.94 green:0.94 blue:0.94
                                                 alpha:1.0]];
        settingsButton = [[SettingsButton alloc] init];
        

        // listen to the map change event
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(updatePanel)
                       name:GameSetupNotification
                     object:nil];
        
        [center addObserver:self
                   selector:@selector(stopTimerAction:)
                       name:GameCleanupNotification
                     object:nil];
        
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame ViewController:(ViewController*) viewController{
    
    self = [TaskBasePanel sharedManager];
    self.frame = frame;
    if (self){
        
    }
    
    return self;
}

- (void)addPanel{
    
    float panelHeight = self.rootViewController.view.frame.size.height -
    self.rootViewController.mapView.frame.size.height;
    // Move the map to the top
    float mapWidth = self.rootViewController.mapView.frame.size.width;
    float mapHeight = self.rootViewController.mapView.frame.size.height;
//    self.rootViewController.mapView.frame = CGRectMake(0, 0, mapWidth, mapHeight);
    
    // Set up the frame of the panel
    self.frame = CGRectMake(0, 0, mapWidth, panelHeight);
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

#pragma makr --Update--
- (void)updatePanel{
    // Get the gameManager
    GameManager *gameManager = [GameManager sharedManager];
    self.instructionsOutlet.text = gameManager.activeSnapshot.instructions;
    self.counterOutlet.text = [NSString stringWithFormat:@"%d", gameManager.gameCounter];
    
    // Start to update the timer
    startDate = [NSDate date];
    
    // this function is to check wheter the map has been touched
    float timer_interval = 0.06;
    updateTimer = [NSTimer timerWithTimeInterval:timer_interval
                                             target:self
                                           selector:@selector(timerAction)
                                           userInfo:nil
                                            repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:updateTimer forMode:NSRunLoopCommonModes];
}

- (void)timerAction{
    double elapsedTime = fabs([startDate timeIntervalSinceNow]);
    self.timeOutlet.text =
    [NSString stringWithFormat:@"Elapsed time: %g", elapsedTime];
}

- (IBAction)stopTimerAction:(id)sender {
    [updateTimer invalidate];
}

@end
