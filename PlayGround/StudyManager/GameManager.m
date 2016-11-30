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

NSString *const GameSetupNotification = @"GameSetupNotification";
NSString *const GameCleanupNotification = @"GameCleanupNotification";

@implementation GameManager

#pragma mark --Initialization--

+ (id)sharedManager{
    static GameManager *sharedGameManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGameManager = [[GameManager alloc] init];
        sharedGameManager.gameManagerStatus = OFF;
        sharedGameManager.gameCounter = -1; // set the game counter to an invalid integer
    });
    return sharedGameManager;
}

#pragma mark --Setter--

- (void)setGameManagerStatus:(GameManagerStatus)gameManagerStatus{
    
    //-------------------
    // Set the rootViewController (this part can be refactored with a singleton)
    //-------------------
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    UINavigationController *myNavigationController =
    app.window.rootViewController;
    ViewController *rootViewController = [myNavigationController.viewControllers objectAtIndex:0];
    MainViewManager *mainViewManager = rootViewController.mainViewManager;
    
    _gameManagerStatus = gameManagerStatus;
    EntityDatabase *entityDB = [EntityDatabase sharedManager];
    switch (gameManagerStatus) {
        case OFF:
            // Turn off the game
            
            rootViewController.spaceBar.isYouAreHereEnabled = YES;
            
            // set the EntityDatabase to use the normal entityArray
            [entityDB removeGameEntityArray];
            
            [mainViewManager showDefaultPanel];
            
            break;
        case STUDY:
            // Turn on the game
            snapshotDatabase = [SnapshotDatabase sharedManager];
            recordDatabase = [RecordDatabase sharedManager];
            [recordDatabase initWithSnapshotArray:snapshotDatabase.snapshotArray];
            
            rootViewController.spaceBar.isYouAreHereEnabled = NO;
            [mainViewManager showPanelWithType: TASKBASEPANEL];
            break;
        case DEMO:
            //<#statements#>
            break;
        case AUTHORING:
            [mainViewManager showPanelWithType: AUTHORINGPANEL];
            break;
        default:
            break;
    }
}

#pragma mark --Game Execution--

// Execute a specific snapshot
- (void)runSnapshotIndex:(int)index{
    
    // Clean the activeSnapshot if there is one
    [self terminateActiveSnapshot];
    
    self.gameCounter = index;
    
    Snapshot *aSnapshot = snapshotDatabase.snapshotArray[index];
    self.activeSnapshot = aSnapshot;
    
    
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
    if ((self.gameCounter + 1) == [snapshotDatabase.snapshotArray count]){
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
    
    Snapshot *aSnapshot = snapshotDatabase.snapshotArray[self.gameCounter];
    
    
    
    
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
        
        self.activeSnapshot = nil;
    }
}
@end
