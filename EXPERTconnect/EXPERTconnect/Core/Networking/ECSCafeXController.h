//
//  ECSCafeXController.h
//  EXPERTconnect
//
//  Created by Nathan Keeney on 8/12/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#ifndef EXPERTconnect_ECSCafeXController_h
#define EXPERTconnect_ECSCafeXController_h

#import <ACBClientSDK/ACBUC.h>
#import "ReachabilityManager.h"
#import "ECSCafeXVideoViewController.h"
#import "ECSRootViewController.h"

@interface ECSCafeXController : NSObject <ACBUCDelegate, ACBClientCallDelegate, ACBClientPhoneDelegate, ReachabilityManagerListener> {
    
    ACBUC *cafeXConnection;
    NSString *username;
    NSString *configuration; // Session ID
    NSString *server; // TODO: Store somewhere
    NSString *port; // TODO: Store somewhere
}

@property (retain) ReachabilityManager *reachabilityManager;
@property (strong, nonatomic) ECSCafeXVideoViewController *cafeXVideoViewController;
@property (copy) void (^postLoginTask)(void);

- (BOOL)hasCafeXSession;
- (void)setupCafeXSession;
- (void)setupCafeXSessionWithTask:(void (^)(void))task;
- (void)endCafeXSession;
- (void)dial:(NSString *)target withVideo:(BOOL)vid andAudio:(BOOL)aud usingParentViewController:(ECSRootViewController *)parent;

+ (void)requestCameraAccess;

@end

#endif
