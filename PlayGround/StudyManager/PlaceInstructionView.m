//
//  PlaceInstructionView.m
//  lab_Drawing
//
//  Created by Daniel on 11/9/16.
//  Copyright © 2016 Daniel. All rights reserved.
//

#import "PlaceInstructionView.h"
#import "SnapshotPlace.h"
#import "AppDelegate.h"
#import "NavTools.h"

@implementation PlaceInstructionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)prepareInstruction:(SnapshotPlace*) snapShotPlace{
    mySnapShotPlace = snapShotPlace;
    
    //-----------------------
    // Populate the instructions
    //-----------------------
    self.instructionLabel.text = snapShotPlace.instructions;
    
    //-----------------------
    // Parse the key
    //-----------------------
    NSString *key = snapShotPlace.name;
    NSArray *listItems = [key componentsSeparatedByString:@":"];
//    NSString *direction = [ listItems[1]  lowercaseStringWithLocale:nil]; // the second one is the direciton
//    
//    NSDictionary *angleDictionary = @{@"east": @0, @"northeast": @45,
//                                      @"north": @90, @"northwest": @135,
//                                      @"west": @180, @"southwest": @225,
//                                      @"south": @270, @"southeast": @315};
//    double angle = [angleDictionary[direction] doubleValue];
    
    
    double angle = [[listItems lastObject] doubleValue];
    
    // Get the name from the snapshot POI
    POI* aPOI;
    if ([snapShotPlace.poisForSpaceTokens count] != 1){
        // Alert the user something is wrong
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Snapshot Data Error."
                            message:@"SnapshotPlace should contain one token POI."
                            delegate:self
                            cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }else{
        aPOI = snapShotPlace.poisForSpaceTokens[0];
    }
    
    NSString *anchorName = aPOI.name;

    CAShapeLayer *baseLayer = [CAShapeLayer layer];
    //----------------------
    // Draw the cirlce layer
    //----------------------
    double radius = 375/4;
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    [circleLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(-radius, -radius, radius*2, radius*2)] CGPath]];
    
    [circleLayer setStrokeColor:[[UIColor clearColor] CGColor]];
    [circleLayer setFillColor:[[UIColor redColor] CGColor]];
    [baseLayer addSublayer:circleLayer];
    
    //----------------------
    // Drawing text onto CALayer
    //----------------------
    CATextLayer *label = [[CATextLayer alloc] init];
    [label setFont:@"Helvetica-Bold"];
    [label setFontSize:20];
    [label setFrame:CGRectMake(0, 0, 70, 30)];
    [label setString:@"station"];
    [label setAlignmentMode:kCAAlignmentCenter];
    [label setForegroundColor:[[UIColor blackColor] CGColor]];
    
    // Translate the text layer
    double thetaInCGCoord = -angle + 180;
    double leg = radius * 1.3;
    double xOffset = cos(thetaInCGCoord/180*M_PI) * leg;
    double yOffset = sin(thetaInCGCoord/180*M_PI) * leg;
    
    label.transform = CATransform3DMakeTranslation(xOffset, yOffset, 0);
    [baseLayer addSublayer:label];
    
    // http://stackoverflow.com/questions/28442516/ios-an-easy-way-to-draw-a-circle-using-cashapelayer
    
    //--------------------
    // Translate the base layer
    //--------------------
    baseLayer.transform = CATransform3DMakeTranslation(375/2, 667/2, 0);
    
    [[self layer] addSublayer:baseLayer];
    
    
    //--------------------
    // Modify the instruction background if it is a demo
    //--------------------
    if ([snapShotPlace.name rangeOfString:@"demo"].location == NSNotFound) {
        // Real task
        [self.demoBanner setHidden:YES];
    } else {
        // Demo
        [self.demoBanner setHidden:NO];
    }
}


- (void)showInstruction{
    // Add the instruction panel to the current view

    //-------------------
    // Set the rootViewController
    //-------------------
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    UINavigationController *myNavigationController =
    app.window.rootViewController;
    UIViewController *rootViewController = [myNavigationController.viewControllers objectAtIndex:0];
    
    // Adjust the size of the view
    self.frame = rootViewController.view.frame;
    
    // Need to put the instruction view in front (from the main thread)
    // to cover SnapTokenCollectionView
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [rootViewController.view addSubview:self];
        [rootViewController.view bringSubviewToFront:self];
    }];

}

- (IBAction)okTapped:(id)sender {
    [self removeFromSuperview];
    // Start the timer
    [mySnapShotPlace.record start];
}

@end
