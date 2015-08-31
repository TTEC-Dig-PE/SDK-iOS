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
    if (cafeXConnection == nil) {
        [self loginToCafeX];
    } else {
        [cafeXConnection startSession];
    }
}

- (void) setupCafeXSessionWithTask:(void (^)(void))task {
    self.postLoginTask = task;
    if (cafeXConnection == nil) {
        [self loginToCafeX];
    } else {
        [cafeXConnection startSession];
    }
}

- (BOOL) hasCafeXSession {
    return cafeXConnection != nil;
}

- (NSString *) cafeXUsername {
    return [[UIDevice currentDevice] identifierForVendor].UUIDString;
}

- (void) loginToCafeX {
    ECSConfiguration *ecsConfiguration = [[ECSInjector defaultInjector] objectForClass:[ECSConfiguration class]];
    // TODO: Get App Server host from configuration (need to add to all host apps too)
    
    username = [self cafeXUsername];
    server = @"dcapp01.ttechenabled.net"; // TODO: Store somewhere
    port = @"443"; // TODO: Store somewhere
    
    NSString *URL    = [NSString stringWithFormat:@"https://%@:%@/cafexproxy/cafexproxy/getsession?u=%@", server, port, username];

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
}

- (void)dial:(NSString *)target withVideo:(BOOL)vid andAudio:(BOOL)aud usingParentViewController:(ECSRootViewController *)parent {
    [ECSCafeXController requestCameraAccess];
    
    _savedTarget = target;
    _savedVidOption = vid;
    _savedAudOption = aud;
    
    _cafeXVideoViewController = [ECSCafeXVideoViewController ecs_loadFromNib];
    
    _cafeXVideoViewController.delegate = self;
    
    [parent presentModal:_cafeXVideoViewController withParentNavigationController:parent.navigationController];
    
    ACBClientPhone* phone = cafeXConnection.phone;
    phone.delegate = self;
}


- (void)CafeXViewDidAppear {
    ACBClientPhone* phone = cafeXConnection.phone;
    
    phone.previewView = _cafeXVideoViewController.previewVideoView;
    
    if (_savedCall == nil) {
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
        _savedCall.videoView = _cafeXVideoViewController.remoteVideoView;
        [_savedCall answerWithAudio:YES video:YES];
    }
}

- (void)CafeXViewDidUnload {
    if (_savedCall != nil) {
        [_savedCall end];
    }
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
    [ACBClientPhone requestMicrophoneAndCameraPermission:TRUE video:TRUE];
}

#pragma mark - ACBUCDelegate


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

# pragma mark - ACBClientCallDelegate

- (void) phone:(ACBClientPhone*)phone didReceiveCall:(ACBClientCall*)call
{
    // TODO: Pop up a answer/reject dialog?
    [ECSCafeXController requestCameraAccess];
    
    NSLog(@"CafeX Incoming Call! Auto-Answering...");
    
    _savedCall = call;
    
    _cafeXVideoViewController = [ECSCafeXVideoViewController ecs_loadFromNib];
    
    _cafeXVideoViewController.delegate = self;
    
    [_defaultParent presentModal:_cafeXVideoViewController withParentNavigationController:_defaultParent.navigationController];
    
    phone.delegate = self;
    
    if (call)
    {
        call.delegate = self;
    }
    else
    {
        NSLog(@"Call is null on didReceiveCall!");
    }
}

- (void) call:(ACBClientCall *)call didReceiveCallRecordingPermissionFailure:(NSString *)message
{
    // TODO: Translate
    NSLog(@"CafeX Error: No permission to access camera or microphone! %@", message);
    [[[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Unable to initiate call: You have not given permission to access the camera or microphone." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    
    // TODO: Kill session?
}

- (void) call:(ACBClientCall*)call didReceiveCallFailureWithError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:@"ERROR (for call)" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}
- (void) call:(ACBClientCall *)call didReceiveDialFailureWithError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:@"ERROR (for call)" message:@"The call could not be connected." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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

#pragma mark - ReachabilityManagerListener
- (void) reachabilityDetermined:(BOOL)reachability
{
    NSLog(@"Network reachability changed to:%@ - here the application has the chance to inform the user that connectivitiy is lost", reachability ? @"YES" : @"NO");
    [cafeXConnection setNetworkReachable:reachability];
}

@end