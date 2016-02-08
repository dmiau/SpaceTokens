//
//  ViewController.m
//  PlayGround
//
//  Created by dmiau on 1/28/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "ViewController.h"
#import "tester.h"


// This is an extension (similar to a category)
@interface ViewController ()

@property NSNumber *touchFlag;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Add a mapView
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 75,
                                                              self.view.frame.size.width, self.view.frame.size.height - 75)];
    [self.view addSubview:self.mapView];
    
    // Add a SpaceBar
    _spaceBar = [[SpaceBar alloc] initWithMapView:_mapView];    
    
    // Place a button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button addTarget:self
               action:@selector(buttonUp:)
     forControlEvents:UIControlEventTouchUpInside];
    

    [button addTarget:self
               action:@selector(buttonDown:)
     forControlEvents:UIControlEventTouchDown];
    

    [button addTarget:self
               action:@selector(buttonDragging: forEvent:)
     forControlEvents:UIControlEventTouchDragInside];
    
    [button setTitle:@"Show View" forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 100.0, 160.0, 40.0);
    
    [button setBackgroundColor:[UIColor blueColor]];
    [button setTitleColor: [UIColor whiteColor]
                 forState: UIControlStateNormal];

    self.myButton = button;
    [self.view addSubview:button];
    
    
    // Run the test
    Tester *tester = [[Tester alloc] init];
    [tester runTests];    
}

//-----------
// button methods
//-----------
- (void) buttonDown:(id)sender {
    NSLog(@"Touch down!");
    self.touchFlag = [NSNumber numberWithBool:YES];
}

- (void) buttonUp:(id)sender {
    NSLog(@"Touch up!");
    self.touchFlag = [NSNumber numberWithBool:NO];
}

- (void) buttonDragging:(UIControl *)sender forEvent: (UIEvent *)event {
//    NSLog(@"Button dragging!");
//    UIButton *bt = (UIButton *) sender;
    UITouch *touch = [[event allTouches] anyObject];
    
//    bt.center = [[[event allTouches] anyObject] locationInView:self.view];
    
    CGPoint locationInView = [touch locationInView:self.view];
    CGPoint previousLoationInView = [touch previousLocationInView:self.view];
    CGPoint locationInButton = [touch locationInView:self.myButton];
    
    self.myButton.center = CGPointMake
    (self.myButton.center.x + locationInView.x - previousLoationInView.x,
     self.myButton.center.y + locationInView.y - previousLoationInView.y);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-----------
// detect touches
//-----------

- (void) touchesMoved:(NSSet<UITouch *> *)touches
            withEvent:(UIEvent *)event
{
    if (self.touchFlag == [NSNumber numberWithBool:YES]){
        UITouch *touch = [touches anyObject];
        CGPoint locationInView = [touch locationInView:self.view];
        CGPoint locationInButton = [touch locationInView:self.myButton];
        self.myButton.frame = CGRectMake(locationInView.x - locationInButton.x, locationInView.y - locationInButton.y, 160.0, 40.0);
        NSLog(NSStringFromCGPoint(locationInView));
    }
}

@end
