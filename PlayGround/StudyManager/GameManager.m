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


@implementation GameManager

- (id)initWithSnapshotDatabase: (SnapshotDatabase*) snapshotDatabase
                    GameVector:(NSArray*) gameVector
{
    self = [super init];
    if (self){
        
        // Get the rootViewController
        
        
        self.gameManagerStatus = OFF;
        self.gameCounter = 0;
        self.gameVector = gameVector;
        self.snapshotDatabase = snapshotDatabase;
    }
    return self;
}

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
            //<#statements#>
            break;
        default:
            break;
    }
}


// Execute a specific snapshot
- (void)runSnapshotIndex:(int)index{
    self.gameCounter = index;
    NSString *code = self.gameVector[index];
    id<SnapshotProtocol> aSnapshot = self.snapshotDatabase.snapshotDictrionary[code];
    [aSnapshot setup];
}

- (void)reportCompletionFromSnashot:(id<SnapshotProtocol>) snapshot{
    
}
@end
