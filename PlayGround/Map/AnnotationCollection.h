//
//  AnnotationCollection.h
//  SpaceBar
//
//  Created by Daniel on 1/30/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnnotationProtocol.h"

@interface AnnotationCollection : NSObject{
    NSMutableArray <id <AnnotationProtocol>> *contentArray;
}

+ (AnnotationCollection*)sharedManager;

// Methods to modify contentArray
-(void)addObject:(id <AnnotationProtocol>)object;
-(void)removeObject:(id <AnnotationProtocol>)object;

-(NSArray <id <AnnotationProtocol>> *)getContent;
-(void)setContent:(NSArray <id <AnnotationProtocol>> *)inputArray;

-(void)resetAnnotations;

@end
