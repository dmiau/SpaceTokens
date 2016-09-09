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

NSString *const GameSetupNotification = @"GameSetupNotification";

@implementation GameManager{
    id <SnapshotProtocol> activeSnapshot;
}

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


- (id)initWithSnapshotDatabase: (SnapshotDatabase*) snapshotDatabase
                    GameVector:(NSArray*) gameVector
{
    self = [super init];
    if (self){
        self.gameVector = gameVector;
        self.snapshotDatabase = snapshotDatabase;
    }
    return self;
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
    switch (gameManagerStatus) {
        case OFF:
            // Turn off the game
            [mainViewManager showDefaultPanel];
            break;
        case STUDY:
            // Turn on the game
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
    if (activeSnapshot){
        [activeSnapshot cleanup];
    }
    
    self.gameCounter = index;
    
    NSString *code = self.gameVector[index];
    id<SnapshotProtocol> aSnapshot = self.snapshotDatabase.snapshotDictrionary[code];
    self.activeSnapshot = aSnapshot;
    
    
    // Broadcast a notification about the changing map
    NSNotification *notification = [NSNotification notificationWithName:GameSetupNotification
                                                                 object:self userInfo:nil];
    [[ NSNotificationCenter defaultCenter] postNotification:notification];
            
    [aSnapshot setup];
}

- (void)runNextSnapshot{
    // Check the bound
    if ((self.gameCounter + 1) == [self.gameVector count]){
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
    
    NSString *code = self.gameVector[self.gameCounter];
    id<SnapshotProtocol> aSnapshot = self.snapshotDatabase.snapshotDictrionary[code];
    
    // Present a modal dialog
    UIAlertView *confirmationModal = [[UIAlertView alloc]
                                      initWithTitle:@"Good job!"
                                      message:@""
                                      delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [confirmationModal show];
    
    // Time delay before cleaning up
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC),
                   dispatch_get_main_queue(),
                   ^{
                       [confirmationModal dismissWithClickedButtonIndex:-1 animated:YES];
                       [aSnapshot cleanup];
                       // Proceed to the next game
                       [self runNextSnapshot];
    });
}
@end
