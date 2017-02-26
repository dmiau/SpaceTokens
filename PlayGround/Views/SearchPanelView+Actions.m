//
//  SearchPanelView+Actions.m
//  SpaceBar
//
//  Created by dmiau on 12/12/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SearchPanelView+Actions.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "SpeechEngine.h"
#import "ArrayTool.h"
#import "DrawingView.h"
#import "ToolPalette.h"
#import "SetTool.h"
#import "CustomMKMapView.h"

#import "WildcardGestureRecognizer.h"

@implementation SearchPanelView (Actions)

- (void)dataButtonAction{
    //-------------------
    // Set the rootViewController
    //-------------------
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    UINavigationController *myNavigationController =
    app.window.rootViewController;
    
    ViewController *rootViewController = [myNavigationController.viewControllers objectAtIndex:0];
    
    [rootViewController performSegueWithIdentifier:@"DataSegue"
                                            sender:nil];
}


- (IBAction)prefAction:(id)sender {
    //-------------------
    // Set the rootViewController
    //-------------------
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    UINavigationController *myNavigationController =
    app.window.rootViewController;
    
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController *destinationController = (UIViewController *)[sb instantiateViewControllerWithIdentifier:@"PreferenceTabController"];
    
    CATransition* transition = [CATransition animation];
    transition.duration = .40;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    
    [myNavigationController.view.layer addAnimation:transition
                                             forKey:kCATransition];
    
    [myNavigationController pushViewController:destinationController animated:NO];
//    [myNavigationController presentViewController:destinationController animated:NO completion:nil];
}


- (IBAction)refreshAction:(id)sender {
    [[CustomMKMapView sharedManager] refreshAnnotations];
}


- (IBAction)barToolAction:(id)sender {
    SpaceBar *spaceBar = [SpaceBar sharedManager];
    ArrayTool *arrayTool = [ArrayTool sharedManager];
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    
    if (spaceBar.isBarToolHidden){
        // Turn ON the bar tool
        spaceBar.isBarToolHidden = NO;
        arrayTool.isVisible = YES;
        
        // Adjust map padding
        mapView.edgeInsets = UIEdgeInsetsMake(10, 70, 10, 70);
        [arrayTool reloadData];
    }else{
        // Turn OFF the bar tool
        spaceBar.isBarToolHidden = YES;
        mapView.edgeInsets = UIEdgeInsetsMake(10, 10, 10, 70);
        arrayTool.isVisible = NO;
        
        // Reset the ArrayTool completedly when the ArrayTool is closed
        [ArrayTool resetSharedInstace];
    }
}

//-----------------------
// AreaTool (SetTool) action
//-----------------------
- (IBAction)areaToolAction:(id)sender {
    SetTool *setTool = [SetTool sharedManager];
    
    setTool.isVisible = !setTool.isVisible;
}


- (IBAction)dataAction:(id)sender {
    //-------------------
    // Set the rootViewController
    //-------------------
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    UINavigationController *myNavigationController =
    app.window.rootViewController;
    
    ViewController *rootViewController = [myNavigationController.viewControllers objectAtIndex:0];
    
    [rootViewController performSegueWithIdentifier:@"DataSegue"
                                            sender:nil];
}

// MARK: -- Speech button action
- (IBAction)speechAction:(id)sender {
    [self.rootViewController.speechEngine showDebugLayer];
}



//-----------------------
// Drawing action
//-----------------------

-(void)initDrawingButton{
    //-----------------
    // Initialize custom gesture recognizer
    //-----------------
    
    // Q: Why do I need to use a custom gesture recognizer?
    // A1: Because I need to disable the default rotation gesture recognizer
    // A2: I don't want my touch to be cancelled by other gesture recognizer
    // (http://stackoverflow.com/questions/5818692/how-to-avoid-touches-cancelled-event)
    
    WildcardGestureRecognizer * tapInterceptor = [[WildcardGestureRecognizer alloc] init];
    
    tapInterceptor.touchesBeganCallback = ^(NSSet<UITouch*>* touches, UIEvent * event) {
        [self customTouchesBegan:touches withEvent:event];
    };
    
    tapInterceptor.touchesEndedCallback = ^(NSSet<UITouch*>* touches, UIEvent * event) {
        [self customTouchesEnded:touches withEvent:event];
    };
    
    //    tapInterceptor.touchesMovedCallback = ^(NSSet<UITouch*>* touches, UIEvent * event) {
    //        [self customTouchesMoved:touches withEvent:event];
    //    };
    
    tapInterceptor.touchesCancelledCallback = ^(NSSet<UITouch*>* touches, UIEvent * event) {
        [self customTouchesCancelled:touches withEvent:event];
    };
    
    tapInterceptor.delegate = self;
    
    //--------------------------
    // Add gesture recognizers
    //--------------------------
    
    [self.drawingButton addGestureRecognizer:tapInterceptor];
}

-(void)customTouchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"Drawing touch began.");
    [self switchDrawingView:YES];
}

-(void)customTouchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"Drawing touch Ended.");
    [self switchDrawingView:NO];
}

-(void)customTouchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"Drawing touch Ended.");
    [self switchDrawingView:NO];
}

- (void)switchDrawingView:(BOOL)flag {
    
    static DrawingView *drawingView;
    if (!drawingView){
        // Initialize once
        drawingView = [[DrawingView alloc] init];
    }
    // Get the map object
    CustomMKMapView *mapView = [CustomMKMapView sharedManager];
    
    if (!flag){
        // Hide the drawing view
        [drawingView viewWillDisappear];
        [drawingView removeFromSuperview];
        
    }else{
        // Show the drawing view
        drawingView.frame = mapView.frame;
        [self.rootViewController.view addSubview:drawingView];
        [drawingView viewWillAppear];
    }
}

@end
