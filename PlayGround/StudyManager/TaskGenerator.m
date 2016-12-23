//
//  TaskGenerator.m
//  SpaceBar
//
//  Created by dmiau on 9/26/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "TaskGenerator.h"
#import "SnapshotPlace.h"
#import "SnapshotAnchorPlus.h"
#import "CustomMKMapView.h"
#import "AnchorTaskGenerator.h"
#import "PlaceTaskGenerator.h"
#import "SnapshotDatabase.h"
#import "MyFileManager.h"
#import "NSMutableArray+Tools.h"

@implementation TaskGenerator

#pragma mark --Initialization--

+(TaskGenerator*)sharedManager{
    static TaskGenerator *sharedTaskGenerator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTaskGenerator = [[TaskGenerator alloc] init];
    });
    return sharedTaskGenerator;
}

#pragma mark --Task Generation--
- (id)init{
    self = [super init];
    if (self){
        self.placeTaskNumber = 8;
        self.placeDemoNumber = 3;
        self.anchorTaskNumber = 10;
        self.anchorDemoNumber = 3;
    }
    return self;
}

- (void)generateTaskFiles:(int)fileCount{
    
    SnapshotDatabase *snapshotDatabase = [SnapshotDatabase sharedManager];
    // This is a hack. Essentailly I use SnapshotDatabase to save several copy of SnapshotDatabase
    // Each participant has her own snapshot database
    // Cache the current active snapshot array
    NSMutableArray <Snapshot*> *cachedSnapshotArray = [snapshotDatabase.snapshotArray mutableCopy];
    
    
    //--------------------
    // Generate task dictionary
    //--------------------
    [self generateTaskDictionary];

    //--------------------
    // Generate game vectors
    //--------------------
    [self generateGameVectors:fileCount];
    
    //--------------------
    // Save the temporary files to the disk
    //--------------------
    [self saveIntermediateFiles];
    
    //--------------------
    // Generate a snapshot database for each game vector
    //--------------------
    int i = 0;
    NSMutableArray *linesArray = [[NSMutableArray alloc] init];
    for (NSArray *aVector in self.gameVectorCollection){
        snapshotDatabase.snapshotArray =
        [self generateSnapshotArrayFromGameVector:aVector];

        // Save the key to a line for debug purpose
        [linesArray addObject:[self snapshotArrayToTaskKeyString:snapshotDatabase.snapshotArray]];
        
        // Save the generated snapshot into a new file
        MyFileManager *myFileManager = [MyFileManager sharedManager];
        NSString *dirPath = [myFileManager currentFullDirectoryPath];
        NSString *fileName = [NSString stringWithFormat:@"study%d.snapshot", i];
        NSString *fileFullPath = [dirPath stringByAppendingPathComponent:fileName];
        [snapshotDatabase saveDatatoFileWithName:fileFullPath];
        i++;
    }

    //--------------------
    // Save debug info
    //--------------------
    NSString *fileString = [linesArray componentsJoinedByString:@"\n\n"];
    // Save the generated snapshot into a new file
    MyFileManager *myFileManager = [MyFileManager sharedManager];
    NSString *dirPath = [myFileManager currentFullDirectoryPath];
    NSString *fileFullPath = [dirPath stringByAppendingPathComponent:@"gameVectorCollectionFull.txt"];
    
    BOOL txtSuccessFlag = [fileString writeToFile:fileFullPath atomically:YES encoding:NSUTF8StringEncoding error:nil]? YES: NO;
    
    
    // Restore the original snapshotArray
    snapshotDatabase.snapshotArray = cachedSnapshotArray;
}

- (NSString*)snapshotArrayToTaskKeyString:(NSArray*) snapshotArray{
    NSMutableArray *taskKeyArray = [[NSMutableArray alloc] init];
    for (Snapshot *aSnapshot in snapshotArray){
        [taskKeyArray addObject: aSnapshot.name];
    }
    return [taskKeyArray componentsJoinedByString:@", "];
}

//------------------------------
// Generate a snapshotArray for a given game vector
//------------------------------
- (NSMutableArray*)generateSnapshotArrayFromGameVector:(NSArray*) gameVector{

    NSMutableArray* snapshotArray = [[NSMutableArray alloc] init];
    
    for (NSString *category in gameVector){
        // Here are some examples of gameVector
        // control:anchor:normal,
        // control:place:normal,
        // spacetoken:anchor:mutant,
        // spacetoken:place:mutant
        
        // Essentially: technique:task:dataset
        
        NSArray *components = [category componentsSeparatedByString:@":"];
        NSString *technique = components[0];
        NSString *taskAndDataID = [NSString stringWithFormat:
                                   @"%@:%@", components[1], components[2]];
        
        Condition condition;
        NSString *techniqueString;
        if ([technique isEqualToString:@"control"]){
            // control condition
            condition = CONTROL;
            techniqueString = @"control";
        }else{
            // spacetoken
            condition = EXPERIMENT;
            techniqueString = @"spacetoken";
        }
        
        //------------------
        // Add demo tasks before each technique
        //------------------
        // Get a list of demos associated with a given category
        NSString *tempDemoKey = [NSString stringWithFormat:@"%@:demo", components[1]];
        NSMutableArray *demoIDArray = [taskByCategory[tempDemoKey] mutableCopy];
        [demoIDArray shuffle];
        
        
        //------------------
        // Prepare an array of snapshot
        //------------------
        NSMutableArray *tempSnapshotArray = [[NSMutableArray alloc] init];
        for (NSString *taskID in demoIDArray){
            Snapshot *aSnapshot = [self.gameSnapshotDictionary[taskID] copy];
            aSnapshot.condition = condition;
            aSnapshot.name =
            [NSString stringWithFormat:@"%@:%@", techniqueString, taskID];
            [tempSnapshotArray addObject:aSnapshot];
        }
        
        // Put the task into the array
        [snapshotArray addObjectsFromArray:tempSnapshotArray];
        
        
        //------------------
        // Shuffle the tasks
        //------------------
        // Get a list of tasks associated with a given category
        NSMutableArray *taskIDArray = [taskByCategory[taskAndDataID] mutableCopy];
        [taskIDArray shuffle];
        
        //------------------
        // Prepare an array of snapshot
        //------------------
        [tempSnapshotArray removeAllObjects];
        for (NSString *taskID in taskIDArray){
            Snapshot *aSnapshot = [self.gameSnapshotDictionary[taskID] copy];
            aSnapshot.condition = condition;
            aSnapshot.name =
            [NSString stringWithFormat:@"%@:%@", techniqueString, taskID];
            [tempSnapshotArray addObject:aSnapshot];
        }
        
        // Put the task into the array
        [snapshotArray addObjectsFromArray:tempSnapshotArray];
    }
    
    return snapshotArray;
}


//---------------------
// Generate a task dictionary
//---------------------
- (NSMutableDictionary*)generateTaskDictionary{
    NSMutableDictionary *tempSnapshotDictionary = [[NSMutableDictionary alloc] init];
    
    //-------------------
    // Generate tasks for PLACE
    //-------------------
    PlaceTaskGenerator *placeTaskGenerator = [[PlaceTaskGenerator alloc] init];
    placeTaskGenerator.dataSetID = @"normal";
    [tempSnapshotDictionary addEntriesFromDictionary:
     [placeTaskGenerator generateSnapshotDictionary]];
    
    
    placeTaskGenerator.dataSetID = @"mutant";
    [tempSnapshotDictionary addEntriesFromDictionary:
     [placeTaskGenerator generateSnapshotDictionary]];
    
    placeTaskGenerator.dataSetID = @"demo";
    placeTaskGenerator.randomSeed = 200;
    NSMutableDictionary *placeTaskDictionary =
    [placeTaskGenerator generateSnapshotDictionary];
    
    // shuffle and select the appropriate number for demo
    NSMutableArray *demoKeys = [[placeTaskDictionary allKeys] mutableCopy];
    [demoKeys shuffle];
    NSMutableDictionary *demoPlaceTaskDictionary = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < self.placeDemoNumber; i++){
        demoPlaceTaskDictionary[demoKeys[i]] = placeTaskDictionary[demoKeys[i]];
    }
    [tempSnapshotDictionary addEntriesFromDictionary:demoPlaceTaskDictionary];
    
    //-------------------
    // Generate tasks for ANCHOR
    //-------------------
    
    AnchorTaskGenerator *anchorTaskGenerator = [[AnchorTaskGenerator alloc] init];
    anchorTaskGenerator.dataSetID = @"normal";
    anchorTaskGenerator.randomSeed = 127;
    [tempSnapshotDictionary addEntriesFromDictionary:[anchorTaskGenerator generateSnapshotDictionary]];
    
    anchorTaskGenerator.dataSetID = @"mutant";
    anchorTaskGenerator.randomSeed = 100;
    [tempSnapshotDictionary addEntriesFromDictionary:[anchorTaskGenerator generateSnapshotDictionary]];
    
    
    anchorTaskGenerator.dataSetID = @"demo";
    anchorTaskGenerator.randomSeed = 200;
    NSMutableDictionary *anchorTaskDictionary =
    [anchorTaskGenerator generateSnapshotDictionary];
    
    // shuffle and select the appropriate number for demo
    demoKeys = [[anchorTaskDictionary allKeys] mutableCopy];
    [demoKeys shuffle];
    NSMutableDictionary *demoAnchorTaskDictionary = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < self.anchorDemoNumber; i++){
        demoAnchorTaskDictionary[demoKeys[i]] = anchorTaskDictionary[demoKeys[i]];
    }
    [tempSnapshotDictionary addEntriesFromDictionary:demoAnchorTaskDictionary];
    
    //-------------------
    // Cache the generated dictionary
    //-------------------
    self.gameSnapshotDictionary = tempSnapshotDictionary;
    
    return tempSnapshotDictionary;
}

- (NSArray*)generateGameVectors:(int) gameCount{
    NSMutableArray *outArray = [[NSMutableArray alloc] init];
    
    NSArray *configruationOrderPool =
    @[
      @[@"control:normal", @"spacetoken:mutant"],
      @[@"spacetoken:normal", @"control:mutant"],
      @[@"control:mutant", @"spacetoken:normal"],
      @[@"spacetoken:mutant", @"control:normal"]
      ];
    // Each row specifies a possible technique-dataset order combination. There are four in total
    
    NSArray *taskOrderPool =
    @[
      @[@"anchor:place", @"anchor:place"],
      @[@"anchor:place", @"place:anchor"],
      @[@"place:anchor", @"place:anchor"],
      @[@"place:anchor", @"anchor:place"]
      ];
    // Each row specifies one possible task order combination.
    // Note each study has the same task twice. One for the control technique, the other for the experimental technique.
    
    // There are 4x4 = 16 combinations
    
    int i = 0;
    
    while(i < gameCount){
        
        for (NSArray *aConfiguration in configruationOrderPool){
            // Each configuration contains two elements
            NSArray *components;
            components = [(NSString* )aConfiguration[0] componentsSeparatedByString:@":"];
            NSString *firstTechnique, *firstDataSet, *secondTechnique, *secondDataSet;
            firstTechnique = components[0];
            firstDataSet = components[1];
            
            components = [(NSString* )aConfiguration[1] componentsSeparatedByString:@":"];
            secondTechnique = components[0];
            secondDataSet = components[1];
            
            for (NSArray *aTaskOrder in taskOrderPool){
                components = [(NSString* )aTaskOrder[0] componentsSeparatedByString:@":"];
                NSString *firstTask, *secondTask, *thirdTask, *fourthTask;
                firstTask = components[0];
                secondTask = components[1];
                
                components = [(NSString* )aTaskOrder[1] componentsSeparatedByString:@":"];
                thirdTask = components[0];
                fourthTask = components[1];
                
                NSString *firstDescriptor, *secondDescriptor, *thirdDescriptor, *fourthDescriptor;
                // Assemble one game vector
                firstDescriptor = [NSString stringWithFormat:@"%@:%@:%@", firstTechnique, firstTask, firstDataSet];
                
                secondDescriptor = [NSString stringWithFormat:@"%@:%@:%@", firstTechnique, secondTask, firstDataSet];
                
                thirdDescriptor = [NSString stringWithFormat:@"%@:%@:%@", secondTechnique, thirdTask, secondDataSet];
                
                fourthDescriptor = [NSString stringWithFormat:@"%@:%@:%@", secondTechnique, fourthTask, secondDataSet];
                
                
                NSArray *gameVector = [NSArray arrayWithObjects:
                                       firstDescriptor, secondDescriptor, thirdDescriptor, fourthDescriptor, nil];
                [outArray addObject:gameVector];
                i++; if (i == gameCount) goto endloop;
            }
        }
    }
    
    endloop:
    self.gameVectorCollection = outArray;
    return outArray;
}

-(void)setGameSnapshotDictionary:(NSDictionary *)gameSnapshotDictionary{
    _gameSnapshotDictionary = gameSnapshotDictionary;
    
    taskByCategory = [[NSMutableDictionary alloc] init];
    
    // Populate some internal structures
    NSArray *allKeys = [self.gameSnapshotDictionary allKeys];
    
    NSArray *categories = @[@"anchor:normal", @"anchor:mutant", @"anchor:demo",
                            @"place:normal", @"place:mutant", @"place:demo"];
    
    for (NSString *category in categories){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", category];
        NSArray *result = [allKeys filteredArrayUsingPredicate:predicate];
        taskByCategory[category] = result;
    }
}

//-----------------------
// File I/O
//-----------------------
// saving and loading the object
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.gameVectorCollection forKey:@"gameVectorCollection"];
    [coder encodeObject:self.gameSnapshotDictionary forKey:@"gameSnapshotDictionary"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [self init];
    self.gameVectorCollection = [coder decodeObjectForKey:@"gameVectorCollection"];
    self.gameSnapshotDictionary = [[coder decodeObjectForKey:@"gameSnapshotDictionary"] mutableCopy];
    return self;
}

//// Deep copy
//-(id) copyWithZone:(NSZone *) zone
//{
//    TaskGenerator *object = [[[self class] alloc] init];
//    object.gameVectorCollection = self.gameVectorCollection;
//    object.gameSnapshotDictionary = self.gameSnapshotDictionary;
//    return object;
//}

-(BOOL)saveIntermediateFiles{
    BOOL successFlag = NO;
    
    // Save the generated snapshot into a new file
    MyFileManager *myFileManager = [MyFileManager sharedManager];
    NSString *dirPath = [myFileManager currentFullDirectoryPath];
    NSString *fileFullPath = [dirPath stringByAppendingPathComponent:@"pregeneratedTaskDB.taskdb"];
    // Save the entire database to a file
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject: self];
    
    if ([data writeToFile:fileFullPath atomically:YES]){
        NSLog(@"%@ saved successfully!", fileFullPath);
        successFlag = YES;
    }else{
        NSLog(@"Failed to save %@", fileFullPath);
        successFlag = NO;
    }
    
    // Save gameVector collection to a text file for reviewing
    NSMutableArray *lines = [[NSMutableArray alloc] init];
    for (NSArray *gameVector in self.gameVectorCollection){
        [lines addObject: [gameVector componentsJoinedByString:@", "]];
    }
    
    NSString *fileString = [lines componentsJoinedByString:@"\n\n"];
    fileFullPath = [dirPath stringByAppendingPathComponent:@"gameVectorCollectionCompact.txt"];
    BOOL txtSuccessFlag = [fileString writeToFile:fileFullPath atomically:YES encoding:NSUTF8StringEncoding error:nil]? YES: NO;
    return txtSuccessFlag && successFlag;
}

-(BOOL)loadPregeneratedFiles{
    MyFileManager *myFileManager = [MyFileManager sharedManager];
    NSString *dirPath = [myFileManager currentFullDirectoryPath];
    NSString *fileFullPath = [dirPath stringByAppendingPathComponent:@"pregeneratedTaskDB.taskdb"];
    
    
    // Read content from a file
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:fileFullPath]){
        
        NSData *data = [NSData dataWithContentsOfFile:fileFullPath];
        TaskGenerator *tempTaskGenerator = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        self.gameVectorCollection = tempTaskGenerator.gameVectorCollection;
        self.gameSnapshotDictionary = tempTaskGenerator.gameSnapshotDictionary;
        return YES;
    }else{
        NSLog(@"%@ does not exist.", fileFullPath);
        return NO;
    }
}
@end
