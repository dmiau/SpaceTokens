//
//  SpaceToken.h
//  SpaceBar
//
//  Created by Daniel on 2/1/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SpatialEntity.h"

@class Person;
@class ConnectionTool;
@class WildcardGestureRecognizer;

typedef enum {DOCKED, DRAGGING, ANCHOR_VISIBLE, ANCHOR_INVISIBLE} TokenAppearanceType;

//----------------------------------------
// SpaceToken interface
//----------------------------------------
@interface SpaceToken : UIButton <UIGestureRecognizerDelegate>{
    CGPoint initialTouchLocationInView;
    BOOL hasReportedDraggingEvent;
    NSTimer *anchorVisualTimer;
    WildcardGestureRecognizer * tapInterceptor;
}

@property BOOL isCircleLayerOn;
@property BOOL isLineLayerOn;
@property BOOL isConstraintLineOn;
@property BOOL isDraggable;
@property BOOL isStudyModeEnabled; // Certain features (e.g., creation, deletion) need to be disabled in the study mode

// Touch related properties
@property BOOL isCustomGestureRecognizerEnabled;

@property (weak) UITouch *touch; // to keep tracking of UITouch

@property CAShapeLayer *circleLayer; // signifies the touch poing
@property CAShapeLayer *lineLayer; // shows the line connecting the SpaceToken and the actual location
@property CAShapeLayer *constraintLayer; //used in the relaxed constraint state

@property (weak) SpaceToken *counterPart;
// When a SpaceToken is dragged out, a copy of the current SpaceToken is created (to stay in the docking position), while the current one moves out of the dock.

@property ConnectionTool *connectionTool;
@property TokenAppearanceType appearanceType;
@property (strong) SpatialEntity* spatialEntity;

@property id home;
// The home of a SpaceToken. The home could be mapView (an anchor), TokenCollectionView, or ArrayTool
@property int index;
// index is used to track a SpaceToken's position in a structure (e.g., ArrayTool, SetTool), since visibleCell does not return a correct order.

@property CGPoint mapViewXY;
// mapViwXY caches the (u, v) coordinates *in mapView* of the SpaceToken
@property CGPoint center;

// Pseudo-delegate methods
// A "clone" is created when a token is dragged outside its dock. As a result,
// the newly created "clone" needs to be tied to the original UICollectionView cell.
// didCreateClone is created for such a purpose.
@property void (^didCreateClone)(SpaceToken *clone);

+(SpaceToken*)manufactureTokenForEntity:(SpatialEntity*)spatialEntity;
+(CGSize)getSize;

// flash the token
- (void)flashToken;
- (void)restoreDefaultStyle; // reset the token to default style

// display the anchor circle after some seconds
- (void)showAnchorVisualIndicatorAfter:(double) second;

//-------------------
// Gesture recognition related items
//-------------------

// Custom methods for the gesture recognizer
-(void)initializeGestureRecognizer;
-(void)addButtonActions;
-(void)removeButtonActions;


-(void)customTouchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
-(void)customTouchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
-(void)customTouchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
-(void)customTouchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
-(void)touchMoved:(UITouch*)touch;
-(void)touchEnded;

// Internal methods
- (void) configureAppearanceForType: (TokenAppearanceType) type;
@end
