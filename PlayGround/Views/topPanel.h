//
//  topPanel.h
//  SpaceBar
//
//  Created by dmiau on 7/20/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#ifndef topPanel_h
#define topPanel_h
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class ViewController;

//---------
// topPanel defines the common interface for top panels
//---------
@protocol TopPanel <NSObject>

@required
-(id)initWithFrame: (CGRect)frame ViewController:(ViewController*) viewController;

-(void)addPanel;
-(void)removePanel;
@end

#endif /* topPanel_h */
