//
//  VoiceItManager.m
//  EXPERTconnectDemo
//
//  Created by Nathan Keeney on 6/17/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECSVoiceItManager.h"

//#import <QuartzCore/QuartzCore.h>
#import "ECSVoiceItNetHelper.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSBundle+ECSBundle.h"

@interface ECSVoiceItManager ()

@property (nonatomic, assign) NSInteger countOfEnrollment;

@end

@implementation ECSVoiceItManager

- (BOOL)isInitialized {
    return initialized;
}

- (id)initWithConfig:(NSString *)config {
    self = [super init];
    if (self) {
        [self configure:config];
    }
    return self;
}

- (void)configure:(NSString *)user {
    voiceOverSwitch = TRUE;
    playBackSwitch = FALSE;
    disableAudioSwitch = FALSE;
    _countOfEnrollment = 1;
    
    username = user;
    if (user) {
        username = user;
    } else {
        username = @"guest@email.com";
    }
    
    NSString *beepFilePath = [[NSBundle ecs_bundle] pathForResource:@"beep" ofType:@"wav"];
    NSString *beforeEnrollFilePath = [[NSBundle ecs_bundle] pathForResource:@"beforeenrollment" ofType:@"wav"];

    beepFile = [NSURL fileURLWithPath:beepFilePath];
    beforeEnrollFile = [NSURL fileURLWithPath:beforeEnrollFilePath];
    
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        disableAudioSwitch = !granted;
    }];
    
    // Initialize Voice It user
    if ([self retrieveUserAction]) {
        // User already exists.
        initialized = TRUE;
    } else {
        [self createUserAction];
    }
}

//- (UIViewController *)getVoiceItPanel {
//return [[VoiceItController alloc] initWithNibName:@"VoiceItPanel" bundle:nil];
//}

-(NSString*) sha256:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256(data.bytes, (unsigned int)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
    
}
-(BOOL)isPureInt:(NSString *) string {
    NSScanner * scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

- (void)createUserAction {
    
    ECSVoiceItNetHelper * netHelper = [[ECSVoiceItNetHelper alloc]init];
    NSMutableDictionary * paramDic= [[NSMutableDictionary alloc] init];
    [paramDic setObject:username forKey:@"VsitEmail"];
    [paramDic setObject:[self sha256:@"abcABC123"] forKey:@"VsitPassword"];
    [paramDic setObject:@"566446" forKey:@"VsitDeveloperId"];
    [paramDic setObject:@"Gwen" forKey:@"VsitFirstName"];
    [paramDic setObject:@"Something" forKey:@"VsitLastName"];
    //if (_phone1Text.text !=nil && _phone1Text.text.length>0) {
    //    [paramDic setObject:_phone1Text.text forKey:@"VsitPhone1"];
    //}
    
    NSString *message = nil;
    NSDictionary * dic = [netHelper postRequestAndResponse:@"users" headerParams:paramDic];
    if (dic !=nil) {
        message = [dic objectForKey:@"Result"];
    } else {
        message = @"Internet Connection Needed or Failed!";
    }
    
    if (message != nil) {
        NSLog(@"Create User VoiceIt returned: %@", message);
        initialized = TRUE;
    }
}
- (BOOL)retrieveUserAction {
    NSString * message = nil;
    BOOL success = FALSE;
    
    ECSVoiceItNetHelper * netHelper = [[ECSVoiceItNetHelper alloc]init];
    NSMutableDictionary * paramDic= [[NSMutableDictionary alloc] init];
    [paramDic setObject:username forKey:@"VsitEmail"];
    [paramDic setObject:[self sha256:@"abcABC123"] forKey:@"VsitPassword"];
    [paramDic setObject:@"566446" forKey:@"VsitDeveloperId"];
    
    NSDictionary * dic = [netHelper getRequestAndResponseDic:@"users" headerParams:paramDic];
    if (dic !=nil) {
        if ( [dic objectForKey:@"Result"] == nil) {
            success = TRUE;
            message = [NSString stringWithFormat:@"Found user: %@", [dic objectForKey:@"FirstName"] ];
            //_lastnameText.text = [dic objectForKey:@"LastName"];
            //_phone1Text.text = [dic objectForKey:@"Phone1"];
            //_phone2Text.text = [dic objectForKey:@"Phone2"];
            //_phone3Text.text = [dic objectForKey:@"Phone3"];
        }
        else {
            message = [dic objectForKey:@"Result"];            }
    } else {
        message = @"Internet Connection Needed or Failed!";
    }
    
    if (message != nil) {
        NSLog(@"Retrieve User VoiceIt returned: %@", message);
    }
    return success;
}

- (int)getEnrollments {
    NSString * message = nil;
    
    ECSVoiceItNetHelper * netHelper = [[ECSVoiceItNetHelper alloc]init];
    NSMutableDictionary * paramDic= [[NSMutableDictionary alloc] init];
    [paramDic setObject:username forKey:@"VsitEmail"];
    [paramDic setObject:[self sha256:@"abcABC123"] forKey:@"VsitPassword"];
    [paramDic setObject:@"566446" forKey:@"VsitDeveloperId"];
    
    NSDictionary * result = [netHelper getRequestAndResponseDic:@"enrollments" headerParams:paramDic];
    if (result !=nil) {
        NSArray *resArray = [result objectForKey:@"Result"];
        NSLog(@"Returned enrollments: %@", result);
        return (int)[resArray count];
    } else {
        message = @"Internet Connection Needed or Failed!";
    }
    
    if (message !=nil){
//        UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:nil message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        dispatch_async(dispatch_get_main_queue(), ^{
//            [alertView show];
        });
    }
    
    return 0;
}

- (void)clearEnrollments {
    ECSVoiceItNetHelper * netHelper = [[ECSVoiceItNetHelper alloc]init];
    NSMutableDictionary * paramDic= [[NSMutableDictionary alloc] init];
    [paramDic setObject:username forKey:@"VsitEmail"];
    [paramDic setObject:[self sha256:@"abcABC123"] forKey:@"VsitPassword"];
    [paramDic setObject:@"566446" forKey:@"VsitDeveloperId"];
    
    NSDictionary * result = [netHelper getRequestAndResponseDic:@"enrollments" headerParams:paramDic];
    if (result !=nil) {
        NSArray *resArray = [result objectForKey:@"Result"];
        NSLog(@"Returned enrollments: %@", result);
        for(int i = 0; i < [resArray count]; i++) {
            NSString *enrollmentId = resArray[i];
            
            ECSVoiceItNetHelper * netHelper = [[ECSVoiceItNetHelper alloc]init];
            NSMutableDictionary * paramDic= [[NSMutableDictionary alloc] init];
            [paramDic setObject:username forKey:@"VsitEmail"];
            [paramDic setObject:[self sha256:@"abcABC123"] forKey:@"VsitPassword"];
            [paramDic setObject:@"566446" forKey:@"VsitDeveloperId"];
            
            NSDictionary * dic = [netHelper deleteRequestAndResponse:[NSString stringWithFormat:@"enrollments/%@",enrollmentId] headerParams:paramDic];
            if (dic !=nil) {
                NSString *message = [dic objectForKey:@"Result"];
                NSLog(@"Clearing Enrollment %@ Result: %@", enrollmentId, message);
            } else {
                NSString *message = @"Internet Connection Needed or Failed!";
                NSLog(@"Clearing Enrollment %@ Result: %@", enrollmentId, message);
            }
            
        }
    } else {
        NSString *message = @"Internet Connection Needed or Failed!";
        NSLog(@"Clearing Enrollments Result: %@", message);
    }
    
//    UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:nil message:@"Success" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    dispatch_async(dispatch_get_main_queue(), ^{
//        [alertView show];
    });
}

- (void)recordNewEnrollment {
    NSLog(@"%s", __FUNCTION__);
    if (voiceOverSwitch) {
        [self playBeforeEnroll];
        voiceTimer=[NSTimer scheduledTimerWithTimeInterval:3.2 target:self selector:@selector(playBeepTimer:) userInfo:[NSNumber numberWithBool:YES] repeats:NO];
    } else {
        [self playBeep];
        voiceTimer=[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(startRecordAndShowAlert:) userInfo:[NSNumber numberWithBool:YES] repeats:NO];
    }
}

-(void) playBeep {
    NSError *playerError;
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:beepFile error:&playerError];
    
    if (player == nil)
    {
        NSLog(@"ERror creating player: %@", [playerError description]);
    }
    
    OSStatus result;
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    
    //result = AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof (audioRouteOverride), &audioRouteOverride);
    AVAudioSession *audioSession;
    result = [audioSession overrideOutputAudioPort:audioRouteOverride error:&playerError];
    
    [player play];
}
-(void) playBeepTimer:(NSTimer *) timer {
    [self playBeep];
    voiceTimer=[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(startRecordAndShowAlert:) userInfo:[timer userInfo] repeats:NO];
}
-(void) playBeforeEnroll {
    NSError *playerError;
    
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:beforeEnrollFile error:&playerError];
    
    if (player == nil)
    {
        NSLog(@"Error creating player: %@", [playerError description]);
    }
    player.delegate = self;
    
    OSStatus result;
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    //result = AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof (audioRouteOverride), &audioRouteOverride);
    AVAudioSession *audioSession;
    result = [audioSession overrideOutputAudioPort:audioRouteOverride error:&playerError];
    
    [player play];
}

- (void)startRecordAndShowAlert:(NSTimer *) timer {
//    UIAlertView * alertView = nil;
//    if ([[timer userInfo] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
//        alertView = [[UIAlertView alloc] initWithTitle:@"New Enrollment" message:@"Say: 'Zoos are filled with small and large animals.'" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
//    } else {
//        alertView = [[UIAlertView alloc] initWithTitle:@"Authenticate" message:@"Say: 'Zoos are filled with small and large animals.'" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
//    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Present the alert view..");
//        [alertView show];
    });
    
    recordedFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"RecordedFile.wav"]];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    if(session == nil)
        NSLog(@"Error creating session: %@", [sessionError description]);
    else
        [session setActive:YES error:nil];
    NSDictionary * recordSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     [NSNumber numberWithFloat:11025.0], AVSampleRateKey,
                                     [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                     [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                     [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
                                     [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                                     [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
                                     nil];
    recorder = [[AVAudioRecorder alloc] initWithURL:recordedFile settings:recordSettings error:nil];
    [recorder prepareToRecord];
    [recorder record];
    if ([[timer userInfo] isEqualToNumber:[NSNumber numberWithBool:YES]])
        isEnrollment = YES;
    else
        isEnrollment = NO;
    
//    [self performSelector:@selector(dismissAlertView:) withObject:alertView afterDelay:5];
}

-(void)playbackRecord {
    NSError *playerError;
    
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:recordedFile error:&playerError];
    
    if (player == nil)
    {
        NSLog(@"Error creating player: %@", [playerError description]);
    }
    player.delegate = self;
    
    OSStatus result;
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    //result = AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof (audioRouteOverride), &audioRouteOverride);
    AVAudioSession *audioSession;
    result = [audioSession overrideOutputAudioPort:audioRouteOverride error:&playerError];
    
    [player play];
}
- (void)authenticateAction:(void (^)(NSString *))authCallback {
    NSString * message = nil;
    __authCallback = authCallback; // save for later.
    
    if (voiceOverSwitch) {
        [self playBeforeEnroll];
        voiceTimer=[NSTimer scheduledTimerWithTimeInterval:3.2 target:self selector:@selector(playBeepTimer:) userInfo:[NSNumber numberWithBool:NO] repeats:NO];
    } else {
        [self playBeep];
        voiceTimer=[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(startRecordAndShowAlert:) userInfo:[NSNumber numberWithBool:NO] repeats:NO];
    }
    
    if (message !=nil){
//        UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:nil message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        dispatch_async(dispatch_get_main_queue(), ^{
//            [alertView show];
        });
    }
}
-(void)sendRecordToServer {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString * message = nil;
        
        ECSVoiceItNetHelper * netHelper = [[ECSVoiceItNetHelper alloc]init];
        NSDictionary * resultDic =nil;
        NSMutableDictionary * paramDic= [[NSMutableDictionary alloc] init];
        [paramDic setObject:username forKey:@"VsitEmail"];
        [paramDic setObject:[self sha256:@"abcABC123"] forKey:@"VsitPassword"];
        [paramDic setObject:@"566446" forKey:@"VsitDeveloperId"];
        if (!isEnrollment) {
            [paramDic setObject:[NSString stringWithFormat:@"%d",(int)5.0] forKey:@"VsitAccuracy"];
            [paramDic setObject:[NSString stringWithFormat:@"%d",(int)85.0] forKey:@"VsitConfidence"];
            [paramDic setObject:[NSString stringWithFormat:@"%d",(int)10] forKey:@"VsitAccuracyPasses"];
            [paramDic setObject:[NSString stringWithFormat:@"%d",(int)5] forKey:@"VsitAccuracyPassIncrement"];
            resultDic = [netHelper postWavRequestAndResponseDic:@"authentications" headerParams:paramDic wavData:[[NSData alloc] initWithContentsOfURL:recordedFile]];
        } else {
            resultDic = [netHelper postWavRequestAndResponseDic:@"enrollments" headerParams:paramDic wavData:[[NSData alloc] initWithContentsOfURL:recordedFile]];
        }
        
        if (resultDic != nil) {
            message = [resultDic objectForKey:@"Result"];
            
            if ([message isEqualToString:@"Success"]) {
                if (self.countOfEnrollment <= 2) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self performSelector:@selector(recordNewEnrollment) withObject:nil afterDelay:1];
                    });
                }
            } else {
                
            }
        } else {
            message = @"Internet Connection Needed or Failed!";
        }
        
        if (!isEnrollment) {
            /* Special case: If this is an auth attempt that failed, we don't want to keep the username around. */
            if (![message containsString:@"successful"]) {
                username = nil;
                initialized = FALSE;
            }
            
            __authCallback(message);
        } else {
            if (([message isEqualToString:@"Success"] && self.countOfEnrollment > 2) ||
                (![message isEqualToString:@"Success"])) {
                
                NSLog(@"Enrollment response: %@", message);
//                UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:nil message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [alertView show];
                });
            } else if (self.countOfEnrollment < 3) {
                self.countOfEnrollment++;
            }
        }
    });
    
}

//-(void)dismissAlertView:(UIAlertView *)alertView {
//    [alertView dismissWithClickedButtonIndex:0 animated:YES];
//    [recorder stop];
//    recorder = nil;
//    if (playBackSwitch) {
//        [self playbackRecord];
//        voiceTimer=[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(sendRecordToServer) userInfo:nil repeats:NO];
//    } else {
//        [self sendRecordToServer];
//    }
//}
//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (buttonIndex == [alertView cancelButtonIndex]) {
//        [NSObject cancelPreviousPerformRequestsWithTarget:self];
//        [recorder stop];
//        recorder = nil;
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        [fileManager removeItemAtURL:recordedFile error:nil];
//        recordedFile = nil;
//    }
//}

@end
