//
//  ECSCafeXController.m
//  EXPERTconnect
//
//  Created by Nathan Keeney on 8/12/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

/* CafeX To-Do:
  - Add attributes to Chat request to indicate video mode (see below) and Pass the "username" for target
    -- Until this is available, ASSUME a mode and hardcode a target username
  - IMP Needs new menu items to Dial (and logic to auto-Dial) based on above
  - Make various config items part of ECS Configuration (or elsewhere as appropriate)
  - Need to request camera access at the correct spot (when requesting a video call or when dialing one (IMP)).
  - Use the logged-in SDK username instead of below identifierForVendor  (make unique by prepending with tenant? etc?)
  - Get new iPad and test/finish video code
  - Create View / VC to house preview & remote videos and to show option buttons (transparent? fullscreen?)
  - Handle connectivity errors
  - Implement (at least for logging) all Delegate methods
  - Consumer should end Session and clear out cafeXConnection object when video session ends (or chat ends?! Decide).
 
  - OPTIONAL: Decide between tt:command vs AED for doing remote commands. Might not be needed (yet)...
  - OPTIONAL: Experiment with adding LiveAssist - ask Kevin for details
 */

/* How to access CafeXController from anywhere in SDK:

 ECSCafeXController *cafeXController = [[ECSInjector defaultInjector] objectForClass:[ECSCafeXController class]];
 
 // Optionally, do a login if there's no session:
 if (![cafeXController hasCafeXSession]) {
    [cafeXController setupCafeXSession];
 }

*/

/* CafeX Modes:
 
  - 'videoauto' Video auto start [mutually exclusive with voice auto, and voice/video escalation]
  - 'voiceauto' Voice auto start [mutually exclusive with video auto, and voice/video escalation]
  - 'videocapable' Video escalation allowed [mutually exclusive with voice and video auto start]
  - 'voicecapable' Voice escalation allowed [mutually exclusive with voice and video auto start]
  - 'cobrowsecapable' CafeX Co-Browse escalation allowed (existing Co-Browse Button w/software switch)
 */

/* Options to expose (somewhere?)
 
  - Mute my audio
  - Mute remote audio
  - Hide my camera
  - Revert to audio-only
  - Change from audio-only to video
  - Minimize/Restore video panel
  - End video session
 */

#import "ECSConfiguration.h"
#import "ECSCafeXController.h"
#import "ECSURLSessionManager.h"
#import "ECSRootViewController.h"
#import "ECSInjector.h"
#import "UIViewController+ECSNibLoading.h"

#import <EXPERTconnect/EXPERTconnect.h>

@implementation ECSCafeXController

- (void) setupCafeXSession {
#if TARGET_IPHONE_SIMULATOR || !INCLUDE_CAFEX
    //NSLog(@"setupCafeXSession - CafeX does not support x86_64 archictecture. Feature disabled.");
#else
    if (cafeXConnection == nil) {
        [self loginToCafeX];
    } else {
        [cafeXConnection startSession];
    }
#endif
}

- (void) setupCafeXSessionWithTask:(void (^)(void))task {
#if TARGET_IPHONE_SIMULATOR || !INCLUDE_CAFEX
    //NSLog(@"setupCafeXSessionWithTask - CafeX does not support x86_64 archictecture. Feature disabled.");
#else
    self.postLoginTask = task;
    if (cafeXConnection == nil) {
        [self loginToCafeX];
    } else {
        [cafeXConnection startSession];
    }
#endif
}

- (BOOL) hasCafeXSession {
    return cafeXConnection != nil;
}

- (NSString *) cafeXUsername {
    return [[UIDevice currentDevice] identifierForVendor].UUIDString;
}

- (void) loginToCafeX {
#if TARGET_IPHONE_SIMULATOR || !INCLUDE_CAFEX
    //NSLog(@"loginToCafeX - CafeX does not support x86_64 archictecture. Feature disabled.");
#else
    ECSConfiguration *ecsConfiguration = [[ECSInjector defaultInjector] objectForClass:[ECSConfiguration class]];
    // TODO: Get App Server host from configuration (need to add to all host apps too)
    
    username = [self cafeXUsername];
    //server = @"dcapp01.ttechenabled.net";
    //port = @"443"; // TODO: Store somewhere
    // NSString *URL    = [NSString stringWithFormat:@"https://%@:%@/cafexproxy/cafexproxy/getsession?u=%@", server, port, username];
    
    // mas - 13-oct-2015 - Connection will not work without a populated cafeXHost
    if (!ecsConfiguration.cafeXHost) {
        NSLog(@"CafeX - Login error: cafeXHost is empty.");
        return;
    }
    
    server = ecsConfiguration.cafeXHost;
    NSString *URL    = [NSString stringWithFormat:@"https://%@/cafexproxy/cafexproxy/getsession?u=%@", server, username];

    ECSURLSessionManager *sessionManager = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    [sessionManager externalRequestWithMethod:@"GET"
                                         path:URL
                                   parameters:nil
                                      success:^(id result, NSURLResponse *response) {
                                          if ([result isKindOfClass:[NSDictionary class]]) {
                                              configuration = [result valueForKey:@"sessionid"];
                                              NSLog(@"CafeX Got session ID: %@", configuration);
                                              cafeXConnection = [ACBUC ucWithConfiguration:configuration delegate:self];
                                              
                                              [self registerForReachabilityCallback];
                                              
                                              // TODO?
                                              /*
                                               BOOL acceptUntrustedCertificates = [[[NSUserDefaults standardUserDefaults] objectForKey:@"acceptUntrustedCertificates"] boolValue];
                                               [_uc acceptAnyCertificate:acceptUntrustedCertificates];
                                               
                                               NSNumber *useCookiesNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"useCookies"];
                                               _uc.useCookies = [useCookiesNumber boolValue];
                                               */
                                              
                                              [cafeXConnection startSession];
                                          } else {
                                              NSLog(@"CafeX Error: result is not a Dictionary!");
                                              NSMutableDictionary *userInfo = [NSMutableDictionary new];
                                              userInfo[NSLocalizedFailureReasonErrorKey] = @"Result is not a Dictionary";
                                              // can't call failure block... ?
                                          }
                                      }
                                      failure:^(id result, NSURLResponse *response, NSError *error) {
                                          NSLog(@"CafeX Error calling getSession: %@", error);
                                      }];
#endif
}

- (void)dial:(NSString *)target withVideo:(BOOL)vid andAudio:(BOOL)aud usingParentViewController:(ECSRootViewController *)parent {
#if TARGET_IPHONE_SIMULATOR || !INCLUDE_CAFEX
    NSLog(@"dial - CafeX does not support x86_64 archictecture. Feature disabled.");
#else
    [ECSCafeXController requestCameraAccess];
    
    _savedTarget = target;
    _savedVidOption = vid;
    _savedAudOption = aud;
    
    _cafeXVideoViewController = [ECSCafeXVideoViewController ecs_loadFromNib];
    
    _cafeXVideoViewController.delegate = self;
    
    _defaultParent = parent;
    
    _cafeXVideoViewController.workflowDelegate = _defaultParent.workflowDelegate;
    
    ACBClientPhone* phone = cafeXConnection.phone;
    phone.delegate = self;
    
    if (_defaultParent != nil && _defaultParent.workflowDelegate != nil) {
        [_defaultParent.workflowDelegate presentVideoChatViewController:_cafeXVideoViewController];
    } else if (_defaultParent != nil && _defaultParent.workflowDelegate == nil) {
        // Ad-Hoc or something. Put a warning and continue.
        NSLog(@"WARNING: CafeX Controller showing ViewController without Workflow Delegate present!! Continuing, but this should be fixed.");
        [_defaultParent.navigationController pushViewController:_cafeXVideoViewController animated:YES];
    } else {
        NSLog(@"ERROR: CafeX Controller doesn't have a parent viewcontroller! Aborting.");
    }
#endif
}

- (void)startCoBrowse:(NSString *)target usingParentViewController:(ECSRootViewController *)parent {
#if TARGET_IPHONE_SIMULATOR || !INCLUDE_CAFEX
    NSLog(@"startCoBrowse - CafeX does not support x86_64 archictecture. Feature disabled.");
#else
    ECSConfiguration *ecsConfiguration = [[ECSInjector defaultInjector] objectForClass:[ECSConfiguration class]];
    if (!ecsConfiguration.cafeXAssistHost) {
        NSLog(@"CafeX - Assist error: cafeXAssistHost is empty.");
        return;
    }
    
    NSDictionary *config = @{
                             @"videoMode": @"none",
                             @"acceptSelfSignedCerts": @YES,
                             @"correlationId": target
                             };
    [AssistSDK startSupport:ecsConfiguration.cafeXAssistHost supportParameters:config]; // TODO: Store host somewhere...
#endif
}


- (void)CafeXViewDidAppear {
#if TARGET_IPHONE_SIMULATOR || !INCLUDE_CAFEX
    NSLog(@"CafeXViewDidAppear - CafeX does not support x86_64 archictecture. Feature disabled.");
#else
    NSLog(@"CafeX Displayed View Controller (DidAppear)");
    ACBClientPhone* phone = cafeXConnection.phone;
    
    phone.previewView = _cafeXVideoViewController.previewVideoView;
    
    if (_savedCall == nil) {
        NSLog(@"CafeX Dialing remote party... %@", _savedTarget);
        // need to dial it:
        _savedCall = [phone createCallToAddress:_savedTarget audio:_savedAudOption video:_savedVidOption delegate:self];
        
        _savedCall.videoView = _cafeXVideoViewController.remoteVideoView;
        
        
        if (_savedCall)
        {
            _savedCall.delegate = self;
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"ERROR (for call)" message:@"A call must be created with media." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    } else {
        // need to answer it:
        NSLog(@"CafeX ANSWERING Incoming Call... %@", _savedCall);
        _savedCall.videoView = _cafeXVideoViewController.remoteVideoView;
        
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            NSLog(@"CafeX ANSWERING after 2 second delay.");
            [_savedCall answerWithAudio:YES video:YES];
        });
        
        //[_savedCall answerWithAudio:YES video:YES];
    }
#endif
}

- (void)CafeXViewDidUnload {
#if TARGET_IPHONE_SIMULATOR || !INCLUDE_CAFEX
    NSLog(@"CafeXViewDidUnload - CafeX does not support x86_64 archictecture. Feature disabled.");
#else
    if (_savedCall != nil) {
        [_savedCall end];
    }
#endif
}

- (void)CafeXViewDidMuteAudio:(BOOL)muted {
#if TARGET_IPHONE_SIMULATOR || !INCLUDE_CAFEX
    NSLog(@"CafeXViewDidMuteAudio - CafeX does not support x86_64 archictecture. Feature disabled.");
#else
    [_savedCall enableLocalAudio:!muted];
#endif
}
- (void)CafeXViewDidHideVideo:(BOOL)hidden {
#if TARGET_IPHONE_SIMULATOR || !INCLUDE_CAFEX
    NSLog(@"CafeXViewDidHideVideo - CafeX does not support x86_64 archictecture. Feature disabled.");
#else
    [_savedCall enableLocalVideo:!hidden];
    
    [_cafeXVideoViewController hideVideoPanels:hidden];
#endif
}
- (void)CafexViewDidEndVideo {
#if TARGET_IPHONE_SIMULATOR || !INCLUDE_CAFEX
    NSLog(@"CafexViewDidEndVideo - CafeX does not support x86_64 archictecture. Feature disabled.");
#else
    if (_savedCall != nil) {
        [_savedCall end];
        _savedCall = nil;
    }
    
//    if (_defaultParent != nil) {
//        [_defaultParent dismissViewControllerAnimated:YES completion:nil];
//    }
#endif
}
- (void)CafeXViewDidMinimize {
    /* no-op */
}

- (void) endCoBrowse {
#if !(TARGET_IPHONE_SIMULATOR) && INCLUDE_CAFEX
    [AssistSDK endSupport];
#endif
}

- (void) endCafeXSession {
    NSLog(@"CafeX Starting logout - Server %@ Configuration %@", server, configuration);
    
    NSString *URL = [NSString stringWithFormat:@"https://%@:%@/cafexproxy/cafexproxy/endsession?id=%@", server, port, configuration];
    
    ECSURLSessionManager *sessionManager = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    [sessionManager externalRequestWithMethod:@"GET"
                                         path:URL
                                   parameters:nil
                                      success:^(id result, NSURLResponse *response) {
                                          // TODO
                                      }
                                      failure:^(id result, NSURLResponse *response, NSError *error) {
                                          NSLog(@"CafeX Error calling endSession: %@", error);
                                      }];
}

- (void)setDefaultParent:(ECSRootViewController *)parent {
    _defaultParent = parent;
}

+ (void) requestCameraAccess {
#if !(TARGET_IPHONE_SIMULATOR) && INCLUDE_CAFEX
    [ACBClientPhone requestMicrophoneAndCameraPermission:TRUE video:TRUE];
#endif
}

#pragma mark - ACBUCDelegate

#if !(TARGET_IPHONE_SIMULATOR) && INCLUDE_CAFEX
/**
 * A notification to indicate that the session has been initialised successfully.
 */
- (void) ucDidStartSession:(ACBUC *)uc
{
    NSLog(@"CafeX DidStartSession (Success)");
    
    cafeXConnection.phone.delegate = self;
    
    if (self.postLoginTask) {
        self.postLoginTask();
    }
}

/**
 * A notification to indicate that initialisation of the session failed.
 */
- (void) ucDidFailToStartSession:(ACBUC *)uc
{
    // TODO: Translate
    NSLog(@"CafeX DidFailToStartSession");
    [[[UIAlertView alloc] initWithTitle:@"Registration error" message:@"CafeX Registration failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

/**
 * A notification to indicate that the session has been invalidated due to a network drop.
 *
 * @param uc
 *            The UC.
 */
- (void) ucDidLoseConnection:(ACBUC *)uc
{
        // TODO: Translate
    NSLog(@"CafeX DidLoseConnection");
    [[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"CafeX Lost network connection. Please log in again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    [self endCafeXSession];
    // TODO On loss of connection - perform new login
}

- (void) ucDidReceiveSystemFailure:(ACBUC *)uc
{
        // TODO: Translate
    NSLog(@"CafeX DidReceiveSystemFailure");
    [[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"CafeX System failure. Please log in again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    [self endCafeXSession];
}

#endif

# pragma mark - ACBClientCallDelegate

#if !(TARGET_IPHONE_SIMULATOR) && INCLUDE_CAFEX

- (void) phone:(ACBClientPhone*)phone didReceiveCall:(ACBClientCall*)call
{
    // TODO: Pop up a answer/reject dialog?
    [ECSCafeXController requestCameraAccess];
    
    NSLog(@"CafeX Incoming Call! Auto-Answering...");
    
    _savedCall = call;
    
    _cafeXVideoViewController = [ECSCafeXVideoViewController ecs_loadFromNib];
    
    _cafeXVideoViewController.delegate = self;
    
    _cafeXVideoViewController.workflowDelegate = _defaultParent.workflowDelegate;
    
    [_cafeXVideoViewController configWithVideo:[call hasRemoteVideo] andAudio:YES];
    
    phone.delegate = self;
    
    if (call)
    {
        call.delegate = self;
    }
    else
    {
        NSLog(@"Call is null on didReceiveCall!");
    }
    
    NSLog(@"CafeX Displaying View Controller...");
    
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSLog(@"CafeX SHOWING UI after 2 second delay.");
        
        if (_defaultParent != nil && _defaultParent.workflowDelegate != nil) {
            [_defaultParent.workflowDelegate presentVideoChatViewController:_cafeXVideoViewController];
        } else if (_defaultParent != nil && _defaultParent.workflowDelegate == nil) {
            // Ad-Hoc or something. Put a warning and continue.
            NSLog(@"WARNING: CafeX Controller showing ViewController without Workflow Delegate present!! Continuing, but this should be fixed.");
            [_defaultParent.navigationController pushViewController:_cafeXVideoViewController animated:YES];
        } else {
            NSLog(@"ERROR: CafeX Controller doesn't have a parent viewcontroller! Aborting.");
        }
    });
}

- (void) call:(ACBClientCall *)call didReceiveCallRecordingPermissionFailure:(NSString *)message
{
    // TODO: Translate
    NSLog(@"CafeX Error: No permission to access camera or microphone! %@", message);
    [self displayErrorAlertWithTitle:@"ERROR"
                         withMessage:@"Unable to initiate call: You have not given permission to access the camera or microphone."];
    // TODO: Kill session?
}

- (void) call:(ACBClientCall*)call didReceiveCallFailureWithError:(NSError *)error {
    [self displayErrorAlertWithTitle:@"ERROR (for call)"
                         withMessage:error.description];

}
- (void) call:(ACBClientCall *)call didReceiveDialFailureWithError:(NSError *)error {
    [self displayErrorAlertWithTitle:@"ERROR (for call)"
                         withMessage:@"The call could not be connected."];
}

- (void) call:(ACBClientCall*)call didChangeStatus:(ACBClientCallStatus)status
{
    switch (status)
    {
        case ACBClientCallStatusRinging:
            NSLog(@"CALL IS STATUS: RINGING");
            break;
        case ACBClientCallStatusAlerting:
            NSLog(@"CALL IS STATUS: ALERTING");
            break;
        case ACBClientCallStatusMediaPending:
            NSLog(@"CALL IS STATUS: MEDIA PENDING");
            break;
        case ACBClientCallStatusInCall:
            NSLog(@"CALL IS STATUS: IN-CALL");
            break;
        case ACBClientCallStatusEnded:
            NSLog(@"CALL IS STATUS: ENDED");
            if (_defaultParent) {
                [_defaultParent.workflowDelegate endVideoChat];
            }
            
            break;
        case ACBClientCallStatusSetup:
            NSLog(@"CALL IS STATUS: IN-SETUP");
            break;
        case ACBClientCallStatusBusy:
            NSLog(@"CALL IS STATUS: BUSY");
            break;
        case ACBClientCallStatusError:
            NSLog(@"CALL IS STATUS: ERROR");
            break;
        case ACBClientCallStatusNotFound:
            NSLog(@"CALL IS STATUS: NOT FOUND");
            break;
        case ACBClientCallStatusTimedOut:
            NSLog(@"CALL IS STATUS: TIMED OUT");
            break;
    }
}

- (void)callDidReceiveMediaChangeRequest:(ACBClientCall *)call {
    [_cafeXVideoViewController didHideRemoteVideo: ![call hasRemoteVideo]];
}

#endif

#pragma mark - Reachability
- (void)registerForReachabilityCallback
{
    // Do any additional setup after loading the view.
    self.reachabilityManager = [[ReachabilityManager alloc] init];
    [self.reachabilityManager addListener:self];
    [self.reachabilityManager registerForReachabilityTo:server];
}

- (void)unregisterForReachabilityCallback
{
    // remove the reachability callback listener
    if (self.reachabilityManager != nil)
    {
        [self.reachabilityManager removeListener:self];
    }
}

- (void)displayErrorAlertWithTitle:(NSString *)title withMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *alertActionStop = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        if (_defaultParent) {
            [_defaultParent.workflowDelegate endVideoChat];
        }
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    
    [alertController addAction:alertActionStop];
    if (_defaultParent) {
        [_defaultParent presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - ReachabilityManagerListener

- (void) reachabilityDetermined:(BOOL)reachability
{
    NSLog(@"Network reachability changed to:%@ - here the application has the chance to inform the user that connectivitiy is lost", reachability ? @"YES" : @"NO");
#if !(TARGET_IPHONE_SIMULATOR) && INCLUDE_CAFEX
    [cafeXConnection setNetworkReachable:reachability];
#endif
}

@end