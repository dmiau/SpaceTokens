//
//  AnnotationCollection.m
//  SpaceBar
//
//  Created by Daniel on 1/30/17.
//  Copyright © 2017 dmiau. All rights reserved.
//

#import "AnnotationCollection.h"
#import "CustomPointAnnotation.h"

@implementation AnnotationCollection

+ (AnnotationCollection*)sharedManager{
    static AnnotationCollection* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AnnotationCollection alloc] init];
    });
    return sharedInstance;
}

-(id)init{
    self = [super init];
    contentArray = [NSMutableArray array];    
    return self;
}


// Methods to modify contentArray
-(void)addObject:(id)object{
    [contentArray addObject:object];
}

-(void)removeObject:(id)object{
    [contentArray removeObject:object];
}

-(NSArray <id <AnnotationProtocol>> *)getContent{
    return contentArray;
}

-(void)setContent:(NSArray <id <AnnotationProtocol>> *)inputArray{
    contentArray = [inputArray mutableCopy];
}


-(void)resetAnnotations{    
    // Get all the annotations
    for (id annotation in contentArray){
        if ([annotation isKindOfClass:[CustomPointAnnotation class]]){
            CustomPointAnnotation *pointAnnotation = annotation;
            pointAnnotation.isHighlighted = NO;
            pointAnnotation.isLabelOn = NO;
        }
    }
}

@end
