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
    for (NSArray *aVector in self.gameVectorCollection){
        snapshotDatabase.snapshotArray =
        [self generateSnapshotArrayFromGameVector:aVector];

        // Save the generated snapshot into a new file
        MyFileManager *myFileManager = [MyFileManager sharedManager];
        NSString *dirPath = [myFileManager currentFullDirectoryPath];
        NSString *fileName = [NSString stringWithFormat:@"study%d.snapshot", i];
        NSString *fileFullPath = [dirPath stringByAppendingPathComponent:fileName];
        [snapshotDatabase saveDatatoFileWithName:fileFullPath];
        i++;
    }

    // Restore the original snapshotArray
    snapshotDatabase.snapshotArray = cachedSnapshotArray;
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
        
        // Get a list of tasks associated with a given category
        NSMutableArray *taskIDArray = [taskByCategory[taskAndDataID] mutableCopy];
        
        //------------------
        // Shuffle the tasks
        //------------------
        [taskIDArray shuffle];
        
        //------------------
        // Prepare an array of snapshot
        //------------------
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
        NSMutableArray *tempSnapshotArray = [[NSMutableArray alloc] init];
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
    NSMutableDictionary *placeTaskDictionary = [placeTaskGenerator generateSnapshotDictionary];
    [tempSnapshotDictionary addEntriesFromDictionary:placeTaskDictionary];
    
    
    placeTaskGenerator.dataSetID = @"mutant";
    placeTaskDictionary = [placeTaskGenerator generateSnapshotDictionary];
    [tempSnapshotDictionary addEntriesFromDictionary:placeTaskDictionary];
    
    //-------------------
    // Generate tasks for ANCHOR
    //-------------------
    
    AnchorTaskGenerator *anchorTaskGenerator = [[AnchorTaskGenerator alloc] init];
    anchorTaskGenerator.dataSetID = @"normal";
    anchorTaskGenerator.randomSeed = 127;
    NSMutableDictionary *anchorTaskDictionary =
    [anchorTaskGenerator generateSnapshotDictionary];
    [tempSnapshotDictionary addEntriesFromDictionary:anchorTaskDictionary];
    
    anchorTaskGenerator.dataSetID = @"mutant";
    anchorTaskGenerator.randomSeed = 100;
    anchorTaskDictionary =
    [anchorTaskGenerator generateSnapshotDictionary];
    [tempSnapshotDictionary addEntriesFromDictionary:anchorTaskDictionary];
    
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
    
    NSArray *categories = @[@"anchor:normal", @"anchor:mutant",
                            @"place:normal", @"place:mutant"];
    
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
    // Save the generated snapshot into a new file
    MyFileManager *myFileManager = [MyFileManager sharedManager];
    NSString *dirPath = [myFileManager currentFullDirectoryPath];
    NSString *fileFullPath = [dirPath stringByAppendingPathComponent:@"pregeneratedTaskDB.taskdb"];
    // Save the entire database to a file
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject: self];
    
    if ([data writeToFile:fileFullPath atomically:YES]){
        NSLog(@"%@ saved successfully!", fileFullPath);
        return YES;
    }else{
        NSLog(@"Failed to save %@", fileFullPath);
        return NO;
    }
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
