//
//  VoiceItManager.h
//  EXPERTconnectDemo
//
//  Created by Nathan Keeney on 6/17/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ECSVoiceItManager : NSObject<UIAlertViewDelegate,AVAudioPlayerDelegate> {
@private
    void (^__authCallback)(NSString *param);
    BOOL isEnrollment;
    NSURL *recordedFile;
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    NSURL * beepFile;
    NSURL * beforeEnrollFile;
    NSTimer *voiceTimer;
    BOOL voiceOverSwitch;
    BOOL playBackSwitch;
    BOOL disableAudioSwitch;
    NSString *username;
    BOOL initialized;
}

- (id)initWithConfig:(NSString *)config;
- (void)configure:(NSString *)user;
- (void)recordNewEnrollment;
- (void)authenticateAction:(void (^)(NSString *))authCallback;
- (void)clearEnrollments;
- (BOOL)isInitialized;

@end