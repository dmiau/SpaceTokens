//
//  GameManager.m
//  SpaceBar
//
//  Created by dmiau on 8/5/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "GameManager.h"
#import "ViewController.h"
#import "AppDelegate.h"
#import "MainViewManager.h"
#import "EntityDatabase.h"
#import "TokenCollection.h"
#import "SnapshotDatabase.h"
#import "RecordDatabase.h"
#import <vector>

using namespace std;
NSString *const GameSetupNotification = @"GameSetupNotification";
NSString *const GameCleanupNotification = @"GameCleanupNotification";

@implementation GameManager{

    ViewController *rootViewController;
    vector<TaskInformationStruct> taskInformationVector;
}

#pragma mark --Initialization--

+ (GameManager*)sharedManager{
    static GameManager *sharedGameManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGameManager = [[GameManager alloc] init];

    });
    return sharedGameManager;
}

- (id)init{
    self = [super init];
    if (self){
        self.gameManagerStatus = OFF;
        self.gameCounter = -1; // set the game counter to an invalid integer
        
        //-------------------
        // Set the rootViewController (this part can be refactored with a singleton)
        //-------------------
        AppDelegate *app = [[UIApplication sharedApplication] delegate];
        
        UINavigationController *myNavigationController =
        app.window.rootViewController;
        rootViewController = [myNavigationController.viewControllers objectAtIndex:0];
    }
    return self;
}

#pragma mark --Setter--

- (void)setGameManagerStatus:(GameManagerStatus)gameManagerStatus{
    MainViewManager *mainViewManager = rootViewController.mainViewManager;
    
    _gameManagerStatus = gameManagerStatus;
    EntityDatabase *entityDB = [EntityDatabase sharedManager];
    switch (gameManagerStatus) {
        case OFF:
            // Clean up if there is an activeSnapshot
            [self terminateActiveSnapshot];
            
            // Turn off the game
            rootViewController.spaceBar.isStudyModeEnabled = NO;
            rootViewController.spaceBar.isAnchorAllowed = YES;
            rootViewController.spaceBar.isMultipleTokenSelectionEnabled = YES;
            [TokenCollection sharedManager].isStudyModeEnabled = NO;
                        
            // set the EntityDatabase to use the normal entityArray
            [entityDB removeGameEntityArray];
            
            [mainViewManager showDefaultPanel];
            
            break;
        case STUDY:
            // Turn on the game
            rootViewController.spaceBar.isStudyModeEnabled = YES;
            [TokenCollection sharedManager].isStudyModeEnabled = YES;
            [mainViewManager showPanelWithType: TASKBASEPANEL];
            break;
        case DEMO:
            rootViewController.spaceBar.isStudyModeEnabled = YES;
            [TokenCollection sharedManager].isStudyModeEnabled = YES;
            [mainViewManager showPanelWithType: TASKBASEPANEL];
            break;
        case AUTHORING:
            [mainViewManager showPanelWithType: AUTHORINGPANEL];
            break;
        default:
            break;
    }
}

-(void)setSnapshotDatabase:(SnapshotDatabase *)snapshotDatabase{
    _snapshotDatabase = snapshotDatabase;
    
    self.recordDatabase = [RecordDatabase sharedManager];
    [self.recordDatabase initWithSnapshotArray:_snapshotDatabase.snapshotArray];    
    self.recordDatabase.name = [_snapshotDatabase.currentFileName stringByDeletingPathExtension];
    
    // Compute the statistics of the gameVector
    taskInformationVector.clear();
    
    NSMutableDictionary *taskKeyDictionary = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *taskKeyArray = [[NSMutableArray alloc] init];
    for (Snapshot *aSnapshot in snapshotDatabase.snapshotArray){
        // Get the first three components
        
        NSString *key = [aSnapshot firstNComponentsFromCode:3];
        if (![taskKeyDictionary objectForKey:key]){
            taskKeyDictionary[key] = [NSNumber numberWithInt:0];
        }else{
            taskKeyDictionary[key] = [NSNumber numberWithInt:
                                      [taskKeyDictionary[key] intValue] + 1];
        }
        TaskInformationStruct taskInfoStruct;
        taskInfoStruct.indexInCategory = [taskKeyDictionary[key] intValue];
        taskInformationVector.push_back(taskInfoStruct);
    }
    
    // Fill in count in category
    int i = 0;
    for (Snapshot *aSnapshot in snapshotDatabase.snapshotArray){
        // Get the first three components
        
        NSString *key = [aSnapshot firstNComponentsFromCode:3];
        taskInformationVector[i].countInCategory =
        [taskKeyDictionary[key] intValue] + 1;
        i++;
    }
}


#pragma mark --Game Execution--

// Execute a specific snapshot
- (void)runSnapshotIndex:(int)index{
    
    // Clean the activeSnapshot if there is one
    [self terminateActiveSnapshot];
    
    self.gameCounter = index;
    
    Snapshot *aSnapshot = _snapshotDatabase.snapshotArray[index];
    self.activeSnapshot = aSnapshot;
    self.activeTaskInformationStruct = taskInformationVector[index];
    
    // Broadcast a notification about the changing map
    NSNotification *notification = [NSNotification notificationWithName:GameSetupNotification
                                                                 object:self userInfo:nil];
    [[ NSNotificationCenter defaultCenter] postNotification:notification];
    
    // set the EntityDatabase to use the temporary POIArray
    EntityDatabase *entityDB = [EntityDatabase sharedManager];
    [entityDB useGameEntityArray:aSnapshot.poisForSpaceTokens];
    [aSnapshot setup];
}

- (void)runNextSnapshot{
    // Check the bound
    if ((self.gameCounter + 1) == [_snapshotDatabase.snapshotArray count]){
        // We have reached the end of the game, display ending message
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"End of the game!"
                                                        message:@"Please notify the study coordinator."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];        
        return;
    }else{
        // Load the next snapshot
        [self runSnapshotIndex:self.gameCounter+1];
    }
}


- (void)reportCompletionFromSnashot:(id<SnapshotProtocol>) snapshot{
    
    Snapshot *aSnapshot = _snapshotDatabase.snapshotArray[self.gameCounter];
    
    
    
    
    // Present a modal dialog
    UIAlertView *confirmationModal = [[UIAlertView alloc]
                                      initWithTitle:@"Good job!"
                                      message:[NSString stringWithFormat:@"Time: %g", aSnapshot.record.elapsedTime]
                                      delegate:self cancelButtonTitle:@"Next" otherButtonTitles:nil];
    [confirmationModal show];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if ([alertView.title isEqualToString:@"End of the game!"]){
        
    }else if ([alertView.title isEqualToString:@"Good job!"]){
        // the user clicked OK
        if (buttonIndex == 0) {
            [self terminateActiveSnapshot];
            // Proceed to the next game
            [self runNextSnapshot];
        }
    }
}


- (void)terminateActiveSnapshot{
    if (self.activeSnapshot){
        [self.activeSnapshot cleanup];
        // Broadcast a notification about the changing map
        NSNotification *notification = [NSNotification notificationWithName:GameCleanupNotification
                                                                     object:self userInfo:nil];
        [[ NSNotificationCenter defaultCenter] postNotification:notification];
        
        // Save the record
        [self.recordDatabase saveToCurrentFile];
        self.activeSnapshot = nil;
    }
}
@end
