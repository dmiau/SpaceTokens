//
//  SpeechEngine.h
//  SpaceBar
//
//  Created by Daniel on 11/1/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Speech/Speech.h>

@class ConstraintDebugView;

@interface SpeechEngine : NSObject{
    SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
    SFSpeechRecognitionTask *recognitionTask;
    AVAudioEngine *audioEngine;
}

@property SFSpeechRecognizer *speechRecognizer;

- (void)startRecording;
- (void)showDebugLayer;
- (void)guiRecordButtonTapped;

// Mark UI elements
@property ConstraintDebugView *constraintDebugView;

@end
