//
//  StudyManager.h
//  SpaceBar
//
//  Created by dmiau on 8/5/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {OFF, STUDY, DEMO, AUTHORING} StudyManagerStatus;


@interface StudyManager : NSObject

@property StudyManagerStatus studyManagerStatus;
@end
