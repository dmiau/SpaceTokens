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
#import "SnapshotProgress.h"
#import "SnapshotChecking.h"
#import "SnapshotAnchorPlus.h"
#import "SnapshotShow.h"
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
    
    
    //-------------
    // The panel needs to be set up differently based on the type of snapshot
    //-------------
    if ([gameManager.activeSnapshot isKindOfClass:[SnapshotAnchorPlus class]]){
        
        // Need to configure the segmentation controller
        [self enableAndConfigureSegmentControlFromSnapshot:
         gameManager.activeSnapshot];
        
        
    }else if ([gameManager.activeSnapshot isKindOfClass:[SnapshotShow class]]){
        [self disableSegmentControl];
        
        // But enable the next button
        [self.nextButtonOutlet setHidden:NO];
        [self.nextButtonOutlet setEnabled:YES];
    }else{
        [self disableSegmentControl];
    }
    
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

- (void)enableAndConfigureSegmentControlFromSnapshot:(Snapshot*) aSnapshot{
    // Unhide and enable the segment control and the button
    [self.segmentControlOutlet setHidden:NO];
    [self.segmentControlOutlet setEnabled:YES];
    
    // Configure the segment control
    [self.segmentControlOutlet removeAllSegments];
    
    int idx = 0;
    for (NSString *segment in aSnapshot.segmentOptions) {
        [self.segmentControlOutlet insertSegmentWithTitle:segment atIndex:idx++ animated:NO];
    }
    
    [self.nextButtonOutlet setHidden:NO];
    [self.nextButtonOutlet setEnabled:NO];
    
    // validation happens when the "next" button is pressed
    
}

- (void)disableSegmentControl{
    [self.segmentControlOutlet setHidden:YES];
    [self.segmentControlOutlet setEnabled:NO];
    
    [self.nextButtonOutlet setHidden:YES];
    [self.nextButtonOutlet setEnabled:NO];
}


- (void)timerAction{
    double elapsedTime = fabs([startDate timeIntervalSinceNow]);
    self.timeOutlet.text =
    [NSString stringWithFormat:@"Elapsed time: %g", elapsedTime];
}

- (IBAction)stopTimerAction:(id)sender {
    [updateTimer invalidate];
}

- (IBAction)segmentControlAction:(id)sender {
    // The next button will be enabled only after an answer is provided.
    [self.nextButtonOutlet setEnabled:YES];
}

- (IBAction)nextButtonAction:(id)sender {
    // Get the gameManager
    GameManager *gameManager = [GameManager sharedManager];
    Snapshot *activeSnapshot = gameManager.activeSnapshot;
    
    // Collect the answer
    int answerIndex = (int)(self.segmentControlOutlet.selectedSegmentIndex);
    if (answerIndex == -1){
        // This should not happen.
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Answer" message:@"You need to provide an answer to proceed."
            delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    }else{
        NSString *answer = activeSnapshot.segmentOptions[answerIndex];
        activeSnapshot.record.userAnswer = [[NSSet alloc] initWithObjects:answer, nil];
        [activeSnapshot segmentControlValidator];
    }
}
@end
