//
//  SpeechEngine.m
//  NavTools
//
//  Created by Daniel on 11/1/16.
//  Copyright © 2016 dmiau. All rights reserved.
//

#import "SpeechEngine.h"
#import "AppDelegate.h"
#import "ConstraintDebugView.h"

@implementation SpeechEngine


// MARK: Initialization
- (id)init{
    self = [super init];
    
    // Initialize a speech recognizer
    self.speechRecognizer = [[SFSpeechRecognizer alloc]
                             initWithLocale:[NSLocale localeWithLocaleIdentifier:@"en-US"]];
    
    self.speechRecognizer.delegate = self;
    
    // Initialize the audioEngine
    audioEngine = [[AVAudioEngine alloc] init];
    
    // Load the debug view
    self.constraintDebugView =
    [[[NSBundle mainBundle] loadNibNamed:@"ConstraintDebugView"
                                   owner:self options:nil] firstObject];
    
    self.constraintDebugView.speechEngine = self; // 
    
    // Initialize the GUI
    [self.constraintDebugView.recordButton setEnabled:YES];
    
    // Gain user's authorization
    [SFSpeechRecognizer requestAuthorization:
    ^void(SFSpeechRecognizerAuthorizationStatus status){
        switch (status) {
            case SFSpeechRecognizerAuthorizationStatusAuthorized:
                [self.constraintDebugView.recordButton setEnabled:YES];
                break;

            case SFSpeechRecognizerAuthorizationStatusDenied:
                [self.constraintDebugView.recordButton setEnabled:NO];
                [self.constraintDebugView.recordButton
                 setTitle:@"User denied access to speech recognition"
                 forState:UIControlStateDisabled];
                break;
                
            case SFSpeechRecognizerAuthorizationStatusRestricted:
                [self.constraintDebugView.recordButton setEnabled:NO];
                [self.constraintDebugView.recordButton
                 setTitle:@"Speech recognition restricted on this device"
                 forState:UIControlStateDisabled];
                break;

            case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                [self.constraintDebugView.recordButton setEnabled:NO];
                [self.constraintDebugView.recordButton
                 setTitle:@"Speech recognition not yet authorized"
                 forState:UIControlStateDisabled];
                break;
                
            default:
                break;
        }
        
        
    }];
    
    return self;
}


// MARK: debug layer
- (void)showDebugLayer{
    
    // Attach the view to the current view
    //-------------------
    // Get the rootViewController
    //-------------------
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    UINavigationController *myNavigationController =
    app.window.rootViewController;
    
    UIViewController *rootViewController =
    (UIViewController*) [myNavigationController.viewControllers objectAtIndex:0];
    
    [rootViewController.view addSubview:self.constraintDebugView];    
}

// MARK: startRecording

- (void)startRecording{
    
    // Cancel the previous task if it's running
    if (recognitionTask){
        [recognitionTask cancel];
        recognitionTask = nil;
    }
    
    // Configure audioSession
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory: AVAudioSessionCategoryRecord error: nil];
    [audioSession setMode:AVAudioSessionModeMeasurement error:nil];
    [audioSession setActive:true withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    
    recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    
    AVAudioInputNode *inputNode = audioEngine.inputNode;
    if (!inputNode){
        [NSException raise:@"FailedToInit"
                    format:@"Audio engine has no input node"];
    }
    
    if (!recognitionRequest){
        [NSException raise:@"FailedToInit"
                    format:@"Unable to created a SFSpeechAudioBufferRecognitionRequest object"];
    }
    
    // Configure request so that results are returned before audio recording is finished
    recognitionRequest.shouldReportPartialResults = true;
    
    // A recognition task represents a speech recognition session.
    // We keep a reference to the task so that it can be cancelled.
    
    recognitionTask = [self.speechRecognizer recognitionTaskWithRequest:recognitionRequest resultHandler:^void(SFSpeechRecognitionResult *result, NSError *error){
        
        bool isFinal = false;
        
        
        // Display the result, if available
        if (result){
            self.constraintDebugView.textView.text = result.bestTranscription.formattedString;
            isFinal = result.isFinal;
        }
        
        if (error || isFinal){
            [audioEngine stop];
            [inputNode removeTapOnBus:0];
            
            recognitionRequest = nil;
            recognitionTask = nil;
            
            [self.constraintDebugView.recordButton setEnabled:YES];
            [self.constraintDebugView.recordButton setTitle:@"Start Recording" forState:UIControlStateNormal];
        }
        
    }];
    
    AVAudioFormat *recordingFormat = [inputNode outputFormatForBus:0];
    
    [inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat
    block:^void(AVAudioPCMBuffer *buffer, AVAudioTime *when){
        if (recognitionRequest){
            [recognitionRequest appendAudioPCMBuffer:buffer];
        }
        
    }];

    [audioEngine prepare];
    
    @try {
        [audioEngine startAndReturnError:nil];
    } @catch (NSException *exception) {
        // do nothing
    }
    
    // Show something to provide visual feedback?
    self.constraintDebugView.textView.text = @"(Go ahead, I'm listening)";
}

// MARK: SFSpeechRecognizerDelegate
- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer
   availabilityDidChange:(BOOL)available{
    
    if (available){
        [self.constraintDebugView.recordButton setEnabled:YES];
        [self.constraintDebugView.recordButton setTitle:@"Start Recording"
                                               forState:UIControlStateNormal];
    }else{
        [self.constraintDebugView.recordButton setEnabled:NO];
        [self.constraintDebugView.recordButton setTitle:@"Recognition not available"
                                               forState:UIControlStateDisabled];
    }
}

// MARK: GUI actions
- (void)guiRecordButtonTapped{
    if (audioEngine.isRunning){
        [audioEngine stop];
        if (recognitionRequest){
            [recognitionRequest endAudio];
        }
        [self.constraintDebugView.recordButton setEnabled:NO];
        [self.constraintDebugView.recordButton setTitle:@"Stopping"
                                               forState:UIControlStateDisabled];
    }else{
        @try {
            [self startRecording];
        } @catch (NSException *exception) {
          
        }
        [self.constraintDebugView.recordButton setTitle:@"Stop recording"
                                               forState:UIControlStateNormal];
    }
}
@end
